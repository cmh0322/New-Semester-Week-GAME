# 🎸 Rhythm Game Execution Guide

This project is a **rhythm game built using the Processing environment and integrated with Arduino**.
To run this project on another PC, follow the steps below.

---

# 🛠 1. Prerequisites & Environment Setup

## Install Processing IDE

Download and install the version compatible with your operating system from:

https://processing.org

---

## Install Required Libraries

This project requires an external sound library.

1. Open **Processing IDE**
2. Go to
   **Sketch → Import Library → Manage Libraries...**
3. Search for **Minim**
4. Click **Install**

**Library Information**

* Library Name: `Minim`
* Author: `ddf.minim`

> Note
> The **Serial library is built-in** in Processing.
> If it is missing, install it using the same method.

---

# 🔌 2. Arduino Connection

1. Connect your **Arduino board** to the computer.
2. Run the game.

If the Arduino operates normally, you are ready to play.

If the Arduino does **not respond**:

1. Open the `.ino` file inside the project folder.
2. Upload it using the **Arduino IDE**.

---

## ⚠ Serial Port Conflict Warning

Processing and the Arduino IDE **cannot use the same Serial Port simultaneously**.

After uploading the code:

**Close the Arduino IDE before running the Processing sketch.**

---

# 🚀 3. How to Run

1. Open the project file in the **Processing IDE**
2. Click the **Play (▶) button** in the top-left corner
3. Move the application window to the **guest monitor**
4. Set the window to **Full Screen**

---

# 📋 Troubleshooting

## 🖥 Adjusting Screen Size

If the window size does not match your monitor, modify the `size()` function at the top of the code.

```java
// Example: Adjust numbers to match your monitor resolution
size(1600, 900);
```

---

## ⚠ No Sound

If sound is not playing:

* Ensure the **Minim library** is correctly installed
* Check your **speaker/headphone connection**
* Verify the **system volume level**
