# LGT-Turbo-Sound-emulator

## Hardware Turbo Sound (Dual AY/YM) emulator for ZX Spectrum based on the high-speed LGT8F328P microcontroller.

> [English](README.en.md) | [Русский](README.md)  

This project features a hardware emulator for two sound coprocessors, AY-3-8910 and YM2149F (complying with the **Turbo Sound** standard), designed for **ZX Spectrum** computers and their clones. The device is powered by the **LGT8F328P** microcontroller. Thanks to its 32 MHz clock speed and advanced architecture, it can process the Spectrum system bus commands with high accuracy and generate lag-free, 6-channel chiptune audio.

## ⚙️ Technical Highlights

*   **Superior Sound Quality:** Utilizes the built-in **8-bit Digital-to-Analog Converter (DAC)** of the LGT8F328P. Unlike traditional PWM emulation, this approach ensures clean chiptune sound without high-frequency switching noise and significantly reduces the required external component count.
*   **Maximum Performance:** Running the LGT8F328P core at 32 MHz provides precise bus timing synchronization.
*   **Full Compatibility:** Complete emulation of the 6-channel Turbo Sound hardware standard.
*   **Cost-Effective & Available:** The LGT8F328P microcontroller is considerably cheaper, faster, and more accessible than the standard ATmega328P.

## 📐 Hardware Layouts

All printed circuit boards were designed using **KiCad**. The repository contains complete project directories, schematics, and production-ready Gerber files compatible with modern PCB fabs (JLCPCB, PCBWay, etc.).

The project supports **4 hardware form-factor variants** to suit different installation needs:

### 1. DIP-28 (Crystal-less)
The most compact variant relying entirely on the internal 32 MHz oscillator. Ideal for tight spaces.
*   [Schematics](Export/TurboSound_LGT_28p.pdf) | [Placement](Export/TurboSound_LGT_28p.html) | [Gerber](Gerber/TS_LGT_28p_Gerber.zip)

### 2. DIP-28 (With Crystal)
A compact layout that includes footprints for an external crystal oscillator (40/48/50 MHz) to achieve absolute timing accuracy.
*   [Schematics](Export/TurboSound_LGT_28p_50MHz.pdf) | [Placement](Export/TurboSound_LGT_28p_50MHz.html) | [Gerber](Gerber/TS_LGT_28p_50_Gerber.zip)

### 3. DIP-40 (Crystal-less)
A convenient drop-in replacement form-factor designed to plug directly into standard vintage ZX Spectrum CPU or sound chip sockets without requiring any extra pin adapters.
*   [Schematics](Export/TurboSound_LGT_40p.pdf) | [Placement](Export/TurboSound_LGT_40p.html) | [Gerber](Gerber/TS_LGT_40p_Gerber.zip)

### 4. DIP-40 (With Crystal)
A full-sized drop-in replacement layout utilizing an external clock generator for the ultimate emulation quality and stability.
*   [Schematics](Export/TurboSound_LGT_40p_50MHz.pdf) | [Placement](Export/TurboSound_LGT_40p_50MHz.html) | [Gerber](Gerber/TS_LGT_40p_50_Gerber.zip)

## 💾 Firmware & Configuration

The project features specific binary builds corresponding to different clock generator modes, as well as separate firmware versions optimized for either **AY-3-8910** or **YM2149F** chips (taking their unique hardware volume envelope tables into account).

### **AY-3-8910 Targeted Firmware**
*   `[TS_Emu_INT_32MHz_AY](Firmware/TS_Emu_INT_32MHz_AY)` — Internal 32 MHz oscillator, AY-3-8910 tables.
*   `[TS_Emu_INT_37MHz_AY](Firmware/TS_Emu_INT_37MHz_AY)` — Internal 37 MHz oscillator, AY-3-8910 tables (*Recommended for crystal-less builds*).
*   `[TS_Emu_EXT_40MHz_AY](Firmware/TS_Emu_EXT_40MHz_AY)` — External 40 MHz clock, AY-3-8910 tables.
*   `[TS_Emu_EXT_48MHz_AY](Firmware/TS_Emu_EXT_48MHz_AY)` — External 48 MHz clock, AY-3-8910 tables.
*   `[TS_Emu_EXT_50MHz_AY](Firmware/TS_Emu_EXT_50MHz_AY)` — External 50 MHz clock, AY-3-8910 tables.

### **YM2149F Targeted Firmware**
*   `[TS_Emu_INT_32MHz_YM](Firmware/TS_Emu_INT_32MHz_YM)` — Internal 32 MHz oscillator, YM2149F tables.
*   `[TS_Emu_INT_37MHz_YM](Firmware/TS_Emu_INT_37MHz_YM)` — Internal 37 MHz oscillator, YM2149F tables (*Recommended for crystal-less builds*).
*   `[TS_Emu_EXT_40MHz_YM](Firmware/TS_Emu_EXT_40MHz_YM)` — External 40 MHz clock, YM2149F tables.
*   `[TS_Emu_EXT_48MHz_YM](Firmware/TS_Emu_EXT_48MHz_YM)` — External 48 MHz clock, YM2149F tables.
*   `[TS_Emu_EXT_50MHz_YM](Firmware/TS_Emu_EXT_50MHz_YM)` — External 50 MHz clock, YM2149F tables.

---

## Flashing Instructions

To flash the LGT8F328P microcontroller, a specialized hardware programmer is required. 

You can easily build one yourself using one of these DIY options:
1.  An **Arduino-based** programmer using [LarduinoISP](Programmer/LarduinoISP.zip).
2.  An **RP2040-based** programmer using [LarduinoISP](Programmer/RP2040_HRDY_LarduinoISP_Prog.zip).

Once your hardware programmer is ready, you can flash the compiled hex files using the **[AVRDUDESS](Programmer/AVRDUDESS-2.18-portable.zip)** GUI software tool.

### Source Code Compilation
The complete source files can be found in the [/Sources](Sources/AY_Emu.rar) directory. The project compiles successfully using **Atmel Studio 7.0**.

---

## 🤝 Credits & Acknowledgments

*   **[Александр Корочинский](https://t.me/AlexKorochinskiy)** — Author of the original high-performance firmware core for AY-3-8910 and YM2149F emulation.
*   **[Alex-2-Graf](https://github.com/Alex-2-Graf)** — Hardware schematics, KiCad PCB routing, optimization, and project curation.

---

## 📜 License

This project is licensed under the MIT License - see the `LICENSE` file for details.
