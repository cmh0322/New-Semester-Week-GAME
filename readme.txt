# 🎸 Rhythm Game Execution Guide

This project is a rhythm game built using the **Processing** environment and integrated with **Arduino**. To run this project on another PC, please follow the steps below.

---

## 🛠 1. Prerequisites & Environment Setup

### Install Processing IDE

- Download and install the version compatible with your OS from [processing.org](https://www.google.com/search?q=https://processing.org/download/).

### Install Libraries

This project requires an external sound library. Follow these steps to install it:

1. Open Processing and go to **[Sketch]** -> **[Import Library...]** -> **[Manage Libraries...]**.
2. Search for **Minim** and click **Install** (Author: `ddf.minim`).
3. *Note: The Serial library is built-in, but if it's missing, install it using the same method.*

---

## 🔌 2. Arduino Connection

1. Connect your Arduino board to the computer.
2. Run the game. If the Arduino operates normally, you are good to go.
3. If the Arduino does not respond, open the `.ino` file in the project folder and **Upload** it using the Arduino IDE.

> [!CAUTION]
**Warning (Serial Port Conflict)**
Since Processing and the Arduino IDE share the same **Serial Port**, they cannot function simultaneously. Please **close the Arduino IDE** after uploading the code before running the Processing sketch.
> 

---

## 🚀 3. How to Run

1. Open the project file in the Processing IDE.
2. Click the **Play (▶)** button in the top-left corner to start the program.
3. Move the application window to the guest monitor and set it to **Full Screen**.

---

## 📋 Troubleshooting

### 🖥 Adjusting Screen Size

If the window size is too large or small for your monitor, modify the `size()` function at the top of the code:

Java

`Example: Adjust numbers to match your monitor's resolution size(1600, 900);`

### ⚠️ No Sound

- Ensure the `Minim` library is correctly installed.
- Check your speaker/headphone connection and system volume levels.