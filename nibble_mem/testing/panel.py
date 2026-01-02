import subprocess
import tkinter as tk
from tkinter import ttk

class FrontPanel(tk.Tk):
    def __init__(self, sim_path: str):
        super().__init__()
        self.title("Nibble Memory Front Panel (64x4)")
        self.resizable(False, False)

        self.proc = subprocess.Popen(
            [sim_path],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
            bufsize=1
        )

        self.din_bits = [tk.IntVar(value=0) for _ in range(4)]
        self.addr_var = tk.StringVar(value="00")
        self.dout_var = tk.StringVar(value="0")
        self.dout_bits_vars = [tk.StringVar(value="0") for _ in range(4)]

        self._build_ui()
        self._step(din=0, store=0, next_=0, prev=0, rst=1)  # reset pulse
        self._step(din=0, store=0, next_=0, prev=0, rst=0)  # release

        self.protocol("WM_DELETE_WINDOW", self.on_close)

    def _build_ui(self):
        pad = {"padx": 10, "pady": 8}

        main = ttk.Frame(self)
        main.grid(row=0, column=0, **pad)

        # Inputs (switches)
        in_frame = ttk.LabelFrame(main, text="DIN (4 switches)")
        in_frame.grid(row=0, column=0, sticky="ew", **pad)

        for i in range(4):
            cb = ttk.Checkbutton(
                in_frame,
                text=f"DIN{i}",
                variable=self.din_bits[i],
                command=self.on_din_change
            )
            cb.grid(row=0, column=i, padx=6, pady=6)

        # Outputs (LEDs)
        out_frame = ttk.LabelFrame(main, text="DOUT (4 LEDs)")
        out_frame.grid(row=1, column=0, sticky="ew", **pad)

        self.led_labels = []
        for i in range(4):
            lbl = ttk.Label(out_frame, textvariable=self.dout_bits_vars[i], width=6, anchor="center")
            lbl.grid(row=0, column=i, padx=6, pady=6)
            self.led_labels.append(lbl)

        # Status
        status = ttk.Frame(main)
        status.grid(row=2, column=0, sticky="ew", **pad)

        ttk.Label(status, text="ADDR:").grid(row=0, column=0, sticky="w")
        ttk.Label(status, textvariable=self.addr_var, width=6).grid(row=0, column=1, sticky="w", padx=6)

        ttk.Label(status, text="DOUT hex:").grid(row=0, column=2, sticky="w", padx=10)
        ttk.Label(status, textvariable=self.dout_var, width=6).grid(row=0, column=3, sticky="w", padx=6)

        # Buttons
        btns = ttk.Frame(main)
        btns.grid(row=3, column=0, sticky="ew", **pad)

        ttk.Button(btns, text="STORE (write + next)", command=self.on_store).grid(row=0, column=0, padx=6)
        ttk.Button(btns, text="NEXT", command=self.on_next).grid(row=0, column=1, padx=6)
        ttk.Button(btns, text="PREV", command=self.on_prev).grid(row=0, column=2, padx=6)
        ttk.Button(btns, text="RESET", command=self.on_reset).grid(row=0, column=3, padx=6)

        # Make “LEDs” look like LEDs (simple)
        style = ttk.Style(self)
        style.configure("Led.TLabel", font=("TkDefaultFont", 12, "bold"))

        for lbl in self.led_labels:
            lbl.configure(style="Led.TLabel")

        self._refresh_led_colors(0)

    def _din_value(self) -> int:
        v = 0
        for i in range(4):
            v |= (self.din_bits[i].get() & 1) << i
        return v

    def _refresh_led_colors(self, dout: int):
        # Not using custom colors/styles too fancy; just show 1/0 with emphasis
        for i in range(4):
            bit = (dout >> i) & 1
            self.dout_bits_vars[i].set("●" if bit else "○")

    def _step(self, din: int, store: int, next_: int, prev: int, rst: int):
        if self.proc.stdin is None or self.proc.stdout is None:
            return

        # Send: DIN_HEX STORE NEXT PREV RST
        self.proc.stdin.write(f"{din:X} {store} {next_} {prev} {rst}\n")
        self.proc.stdin.flush()

        # Read: ADDR_HEX DOUT_HEX
        line = self.proc.stdout.readline().strip()
        if not line:
            return

        a_hex, d_hex = line.split()
        addr = int(a_hex, 16) & 0x3F
        dout = int(d_hex, 16) & 0xF

        self.addr_var.set(f"{addr:02X}")
        self.dout_var.set(f"{dout:X}")
        self._refresh_led_colors(dout)

    def on_din_change(self):
        # Just tick once so you can see stable state (optional)
        self._step(din=self._din_value(), store=0, next_=0, prev=0, rst=0)

    def on_store(self):
        self._step(din=self._din_value(), store=1, next_=0, prev=0, rst=0)

    def on_next(self):
        self._step(din=self._din_value(), store=0, next_=1, prev=0, rst=0)

    def on_prev(self):
        self._step(din=self._din_value(), store=0, next_=0, prev=1, rst=0)

    def on_reset(self):
        self._step(din=0, store=0, next_=0, prev=0, rst=1)  # assert reset
        self._step(din=0, store=0, next_=0, prev=0, rst=0)  # release

    def on_close(self):
        try:
            if self.proc.stdin:
                self.proc.stdin.write("exit\n")
                self.proc.stdin.flush()
        except Exception:
            pass
        try:
            self.proc.terminate()
        except Exception:
            pass
        self.destroy()

if __name__ == "__main__":
    # run from ui/ folder: python3 panel.py
    app = FrontPanel(sim_path="../sim/sim")
    app.mainloop()
