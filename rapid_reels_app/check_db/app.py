"""
Firebase Phone OTP Authentication - Python Test App
======================================================
Uses Firebase Identity Toolkit REST API to send and verify OTPs.

SETUP INSTRUCTIONS:
-------------------
1. Install dependencies:
       pip install requests

2. Fill in your Firebase config below:
       FIREBASE_API_KEY  — from Firebase Console > Project Settings > General > Web API Key
       SERVICE_ACCOUNT_JSON — path to your downloaded google-services / service account JSON

3. IMPORTANT — For the REST API to send OTPs WITHOUT a browser reCAPTCHA,
   you MUST add test phone numbers in Firebase Console:
       Authentication > Sign-in method > Phone > Scroll to "Phone numbers for testing"
       Example: +91XXXXXXXXXX  →  123456

   These test numbers bypass reCAPTCHA entirely and are perfect for desktop/server testing.
   Real phone numbers require a reCAPTCHA token (browser-only). This is a Firebase limitation.

4. Run:
       python firebase_otp_app.py
"""

import json
import tkinter as tk
from tkinter import ttk, messagebox
import requests
import threading

# ─────────────────────────────────────────────
#  🔧  YOUR FIREBASE CONFIG — FILL THESE IN
# ─────────────────────────────────────────────
FIREBASE_API_KEY = "AIzaSyAAuzYnTH6DhyFewO57ITLXa2CJB7B1IX4"   # e.g. "AIzaSyABC123..."
# ─────────────────────────────────────────────

SEND_OTP_URL = (
    f"https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode"
    f"?key={FIREBASE_API_KEY}"
)
VERIFY_OTP_URL = (
    f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber"
    f"?key={FIREBASE_API_KEY}"
)


# ──────────────────────────────────────────────────────────────────────────────
#  Firebase API calls
# ──────────────────────────────────────────────────────────────────────────────

def send_otp(phone_number: str) -> dict:
    """
    Sends an OTP via Firebase.
    phone_number must be in E.164 format, e.g. +919876543210

    NOTE: Firebase REST API requires a reCAPTCHA token for real numbers.
    For test phone numbers added in Firebase Console the token is ignored —
    pass a dummy string.  For real numbers use a browser-based flow instead.
    """
    payload = {
        "phoneNumber": phone_number,
        "recaptchaToken": "test-recaptcha-token"   # Only works for Firebase test numbers
    }
    resp = requests.post(SEND_OTP_URL, json=payload, timeout=15)
    return resp.json()


def verify_otp(session_info: str, otp_code: str) -> dict:
    """Verifies the OTP code against the sessionInfo returned by send_otp."""
    payload = {
        "sessionInfo": session_info,
        "code": otp_code
    }
    resp = requests.post(VERIFY_OTP_URL, json=payload, timeout=15)
    return resp.json()


# ──────────────────────────────────────────────────────────────────────────────
#  GUI Application
# ──────────────────────────────────────────────────────────────────────────────

class FirebaseOTPApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Firebase Phone OTP Tester")
        self.resizable(False, False)
        self.configure(bg="#0f172a")

        self._session_info = None   # holds Firebase sessionInfo between steps
        self._build_ui()
        self._set_step(1)           # start at step 1

    # ── UI construction ──────────────────────────────────────────────────────

    def _build_ui(self):
        # ── Fonts & colours ──
        BG        = "#0f172a"
        CARD      = "#1e293b"
        ACCENT    = "#38bdf8"
        SUCCESS   = "#4ade80"
        ERROR_CLR = "#f87171"
        TEXT      = "#f1f5f9"
        MUTED     = "#94a3b8"
        BORDER    = "#334155"

        self._colors = dict(
            bg=BG, card=CARD, accent=ACCENT, success=SUCCESS,
            error=ERROR_CLR, text=TEXT, muted=MUTED, border=BORDER
        )

        outer = tk.Frame(self, bg=BG, padx=32, pady=32)
        outer.pack()

        # ── Header ───────────────────────────────────────────────────────────
        tk.Label(outer, text="🔥 Firebase", font=("Courier New", 11, "bold"),
                 bg=BG, fg=ACCENT).pack(anchor="w")
        tk.Label(outer, text="Phone OTP Tester",
                 font=("Georgia", 22, "bold"), bg=BG, fg=TEXT).pack(anchor="w")
        tk.Label(outer, text="Verify your Firebase phone auth setup",
                 font=("Courier New", 10), bg=BG, fg=MUTED).pack(anchor="w", pady=(2, 20))

        # ── Step 1 — Send OTP ────────────────────────────────────────────────
        self._card1 = self._make_card(outer)

        self._step1_badge = self._badge(self._card1, "1")
        self._step1_badge.pack(side="left", padx=(0, 12))

        s1_body = tk.Frame(self._card1, bg=CARD)
        s1_body.pack(fill="x", expand=True)

        tk.Label(s1_body, text="Enter Phone Number",
                 font=("Georgia", 13, "bold"), bg=CARD, fg=TEXT).pack(anchor="w")
        tk.Label(s1_body, text="E.164 format  ·  e.g. +919876543210",
                 font=("Courier New", 9), bg=CARD, fg=MUTED).pack(anchor="w", pady=(1, 10))

        phone_row = tk.Frame(s1_body, bg=CARD)
        phone_row.pack(fill="x")

        self._phone_var = tk.StringVar(value="+91")
        self._phone_entry = self._entry(phone_row, self._phone_var, width=22)
        self._phone_entry.pack(side="left", padx=(0, 10))

        self._send_btn = self._btn(phone_row, "Send OTP →", self._on_send)
        self._send_btn.pack(side="left")

        # ── Step 2 — Verify OTP ──────────────────────────────────────────────
        self._card2 = self._make_card(outer)

        self._step2_badge = self._badge(self._card2, "2")
        self._step2_badge.pack(side="left", padx=(0, 12))

        s2_body = tk.Frame(self._card2, bg=CARD)
        s2_body.pack(fill="x", expand=True)

        tk.Label(s2_body, text="Enter OTP Code",
                 font=("Georgia", 13, "bold"), bg=CARD, fg=TEXT).pack(anchor="w")
        tk.Label(s2_body, text="6-digit code sent to your phone",
                 font=("Courier New", 9), bg=CARD, fg=MUTED).pack(anchor="w", pady=(1, 10))

        otp_row = tk.Frame(s2_body, bg=CARD)
        otp_row.pack(fill="x")

        self._otp_var = tk.StringVar()
        self._otp_entry = self._entry(otp_row, self._otp_var, width=14)
        self._otp_entry.pack(side="left", padx=(0, 10))

        self._verify_btn = self._btn(otp_row, "Verify OTP ✓", self._on_verify,
                                     color=SUCCESS)
        self._verify_btn.pack(side="left")

        # ── Status bar ───────────────────────────────────────────────────────
        self._status_var = tk.StringVar(value="Ready. Enter a phone number to begin.")
        self._status_lbl = tk.Label(
            outer, textvariable=self._status_var,
            font=("Courier New", 10), bg=BG, fg=MUTED,
            wraplength=420, justify="left"
        )
        self._status_lbl.pack(anchor="w", pady=(16, 0))

        # ── Result box (hidden initially) ────────────────────────────────────
        self._result_frame = tk.Frame(outer, bg=CARD, padx=16, pady=12)
        self._result_text = tk.Text(
            self._result_frame, font=("Courier New", 9), bg="#0d1b2a",
            fg=ACCENT, width=52, height=8, relief="flat", wrap="word",
            state="disabled"
        )
        self._result_text.pack(fill="both")

        # ── Reset button ─────────────────────────────────────────────────────
        self._reset_btn = tk.Button(
            outer, text="↺  Reset", font=("Courier New", 10),
            bg=CARD, fg=MUTED, relief="flat", padx=12, pady=6,
            activebackground=BORDER, activeforeground=TEXT,
            cursor="hand2", command=self._reset
        )
        self._reset_btn.pack(anchor="e", pady=(10, 0))

    # ── Widget helpers ───────────────────────────────────────────────────────

    def _make_card(self, parent):
        c = self._colors
        frame = tk.Frame(parent, bg=c["card"], padx=20, pady=16,
                         highlightbackground=c["border"], highlightthickness=1)
        frame.pack(fill="x", pady=(0, 12))
        return frame

    def _badge(self, parent, text):
        c = self._colors
        return tk.Label(parent, text=text, font=("Georgia", 14, "bold"),
                        bg=c["accent"], fg="#0f172a", width=2,
                        relief="flat", padx=8, pady=6)

    def _entry(self, parent, var, width=20):
        c = self._colors
        e = tk.Entry(parent, textvariable=var, font=("Courier New", 13),
                     bg="#0d1b2a", fg=c["text"], insertbackground=c["accent"],
                     relief="flat", bd=0, width=width,
                     highlightbackground=c["border"], highlightthickness=1)
        return e

    def _btn(self, parent, label, command, color=None):
        c = self._colors
        color = color or c["accent"]
        return tk.Button(
            parent, text=label, font=("Courier New", 10, "bold"),
            bg=color, fg="#0f172a", relief="flat", padx=16, pady=8,
            activebackground=c["border"], activeforeground=c["text"],
            cursor="hand2", command=command
        )

    # ── Step management ──────────────────────────────────────────────────────

    def _set_step(self, step: int):
        c = self._colors
        dim = "#2d3748"

        if step == 1:
            self._step1_badge.config(bg=c["accent"])
            self._phone_entry.config(state="normal")
            self._send_btn.config(state="normal")
            self._step2_badge.config(bg=dim)
            self._otp_entry.config(state="disabled")
            self._verify_btn.config(state="disabled")
        else:
            self._step1_badge.config(bg=dim)
            self._phone_entry.config(state="disabled")
            self._send_btn.config(state="disabled")
            self._step2_badge.config(bg=c["success"])
            self._otp_entry.config(state="normal")
            self._verify_btn.config(state="normal")
            self._otp_entry.focus_set()

    # ── Status helpers ───────────────────────────────────────────────────────

    def _set_status(self, msg: str, color: str = None):
        c = self._colors
        self._status_var.set(msg)
        self._status_lbl.config(fg=color or c["muted"])

    def _show_result(self, data: dict, success: bool = True):
        c = self._colors
        self._result_text.config(state="normal")
        self._result_text.delete("1.0", "end")
        self._result_text.insert("end", json.dumps(data, indent=2))
        self._result_text.config(state="disabled",
                                 fg=c["success"] if success else c["error"])
        self._result_frame.pack(fill="x", pady=(8, 0))

    # ── Handlers ─────────────────────────────────────────────────────────────

    def _on_send(self):
        phone = self._phone_var.get().strip()
        if not phone.startswith("+") or len(phone) < 8:
            messagebox.showerror("Invalid", "Enter phone in E.164 format, e.g. +919876543210")
            return

        if FIREBASE_API_KEY == "YOUR_FIREBASE_WEB_API_KEY":
            messagebox.showerror(
                "Config Missing",
                "Please set your FIREBASE_API_KEY at the top of this file before running."
            )
            return

        self._send_btn.config(state="disabled", text="Sending…")
        self._set_status("⏳  Sending OTP to " + phone + " …", self._colors["accent"])

        def worker():
            try:
                result = send_otp(phone)
                self.after(0, self._handle_send_result, result)
            except Exception as e:
                self.after(0, self._handle_error, str(e))

        threading.Thread(target=worker, daemon=True).start()

    def _handle_send_result(self, result: dict):
        self._send_btn.config(text="Send OTP →")
        if "sessionInfo" in result:
            self._session_info = result["sessionInfo"]
            self._set_status(
                "✅  OTP sent! Check your phone and enter the code below.",
                self._colors["success"]
            )
            self._show_result({
                "status": "OTP sent successfully",
                "sessionInfo": result["sessionInfo"][:30] + "…"
            }, success=True)
            self._set_step(2)
        else:
            err = result.get("error", {})
            msg = err.get("message", "Unknown error")
            self._set_status(f"❌  Error: {msg}", self._colors["error"])
            self._show_result(result, success=False)
            self._send_btn.config(state="normal")

    def _on_verify(self):
        if not self._session_info:
            messagebox.showerror("Error", "No active session. Send OTP first.")
            return
        code = self._otp_var.get().strip()
        if len(code) != 6 or not code.isdigit():
            messagebox.showerror("Invalid", "OTP must be exactly 6 digits.")
            return

        self._verify_btn.config(state="disabled", text="Verifying…")
        self._set_status("⏳  Verifying OTP…", self._colors["accent"])

        def worker():
            try:
                result = verify_otp(self._session_info, code)
                self.after(0, self._handle_verify_result, result)
            except Exception as e:
                self.after(0, self._handle_error, str(e))

        threading.Thread(target=worker, daemon=True).start()

    def _handle_verify_result(self, result: dict):
        self._verify_btn.config(text="Verify OTP ✓")
        if "idToken" in result:
            self._set_status(
                "🎉  Verified! Firebase auth is working correctly.",
                self._colors["success"]
            )
            uid = result.get("localId", "N/A")
            phone = result.get("phoneNumber", "N/A")
            self._show_result({
                "status": "✅ Authentication successful!",
                "uid": uid,
                "phoneNumber": phone,
                "idToken": result["idToken"][:40] + "…",
                "refreshToken": result.get("refreshToken", "")[:30] + "…"
            }, success=True)
        else:
            err = result.get("error", {})
            msg = err.get("message", "Unknown error")
            self._set_status(f"❌  Verification failed: {msg}", self._colors["error"])
            self._show_result(result, success=False)
            self._verify_btn.config(state="normal")

    def _handle_error(self, msg: str):
        self._send_btn.config(state="normal", text="Send OTP →")
        self._verify_btn.config(state="normal", text="Verify OTP ✓")
        self._set_status(f"❌  Network error: {msg}", self._colors["error"])

    def _reset(self):
        self._session_info = None
        self._otp_var.set("")
        self._result_frame.pack_forget()
        self._set_status("Ready. Enter a phone number to begin.")
        self._set_step(1)
        self._send_btn.config(state="normal", text="Send OTP →")
        self._verify_btn.config(state="disabled", text="Verify OTP ✓")


# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app = FirebaseOTPApp()
    app.mainloop()