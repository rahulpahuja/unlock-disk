# fix_disk_lock.sh

A one-command fix for macOS stuck disk locks caused by accidental drive removal — restores visibility in Disk Utility and `diskutil` instantly.

---

## The Problem

On macOS (tested on macOS 26 Tahoe / M1), if you accidentally unplug an external drive without ejecting it first, the kernel's filesystem daemon (`fskitd`) can hold a stale lock on the raw disk device (`/dev/rdisk*`). This causes:

- Disk Utility taking forever to load or showing a blank drive list
- `diskutil list` hanging indefinitely
- The drive not showing up even after re-plugging

---

## The Fix

### 1. Download the script

```bash
curl -O https://raw.githubusercontent.com/<your-username>/<your-repo>/main/fix_disk_lock.sh
```

Or clone the repo:

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Make it executable (one-time setup)

```bash
chmod +x fix_disk_lock.sh
```

### 3. Run it whenever the issue occurs

```bash
sudo bash fix_disk_lock.sh
```

Then verify your drives are back:

```bash
diskutil list
```

Or simply reopen **Disk Utility** — drives should now appear.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Detects and kills `fskitd` if it holds a stuck filesystem lock |
| 2 | Finds all processes locking raw disk devices (`/dev/rdisk*`) and kills them |
| 3 | Restarts `diskarbitrationd` to cleanly re-enumerate all connected drives |

---

## Requirements

- macOS (tested on **macOS 26 Tahoe**, M1)
- `sudo` privileges

---

## Example Output

```
🔍 Scanning for stuck disk processes...
⚡ Killing fskitd (PID: 3530)...
⚡ Killing processes with raw disk locks: 3530 4562
   Killed PID 3530
   Killed PID 4562
🔄 Restarting diskarbitrationd...

✅ Done. Now run: diskutil list
   Or reopen Disk Utility — your drives should show up.
```

---

## Prevention

To avoid the issue altogether:

- Always eject drives before unplugging: select the drive in Finder and press **Cmd + E**
- Avoid unplugging during active iCloud Drive sync (it can also trigger locks)

---

## License

MIT
