# Variables

| address | size | name | bits  | description                                                          |
| ------- | ---- | ---- | ----- | -------------------------------------------------------------------- |
| ffb7    | -    |      | [3:0] | FDC descriptor: Bit flags of already accessed floppy drives          |
| ffb8    | -    |      | [1:0] | FDC descriptor: Bytes per sector "factor" (bps = 0x80 << f) [^TODO2] |
| ffb9    | -    |      | [2]   | FDC descriptor: Head number (0 or 1)                                 |
|         | -    |      | [1:0] | FDC descriptor: Addressed drive (0 up to 3)                          |
| ffba    | -    |      | [7:4] | FDC descriptor: operation command [^TODO]                            |
|         | -    |      | [3:0] | FDC descriptor: TBD                                                  |
| ffbb    | 1    |      | -     | FDC descriptor: sector number                                        |
| ffbc    | 1    |      | -     | FDC descriptor: track number                                         |
| ffbd    | 2    |      | -     | FDC descriptor: r/w buffer pointer                                   |
| ffbf    | 1    |      | -     | FDC descriptor: max retry for rwfs operations                        |
| ....    |      |      |       |                                                                      |
| ffc7    |      |      |       |                                                                      |
| ffc8    |      |      |       |                                                                      |
| ffc9    |      |      |       |                                                                      |
| ffca    |      |      |       |                                                                      |
| ffcb    |      |      |       |                                                                      |
| ffcc    |      |      |       |                                                                      |
| ffcd    |      |      |       |                                                                      |
| ffce    |      |      |       |                                                                      |
| ffcf    |      |      |       |                                                                      |
| ffd0    |      |      |       |                                                                      |
| ffd1    |      |      |       |                                                                      |
| ffd2    |      |      |       |                                                                      |
| ffd3    |      |      |       |                                                                      |
| ffd4    | 2    | IX   | -     | text cursor X position (?)                                           |
| ffd6    | 2    | IY   | -     | text cursor Y position (?)                                           |
| ffd7    |      |      |       |                                                                      |
| ffd8    |      |      |       |                                                                      |
| ffd9    |      |      |       |                                                                      |
| ffda    |      |      |       |                                                                      |
| ....    |      |      |       |                                                                      |
