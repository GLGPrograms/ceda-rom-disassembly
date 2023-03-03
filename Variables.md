# Variables

# Default bank

| address | size | name           | bits  | description                                                                                                     |
| ------- | ---- | -------------- | ----- | --------------------------------------------------------------------------------------------------------------- |
| ffb7    | -    |                | [3:0] | FDC descriptor: Bit flags of already accessed floppy drives                                                     |
| ffb8    | -    |                | [1:0] | FDC descriptor: Bytes per sector "factor" (bps = 0x80 << f) [^TODO2]                                            |
| ffb9    | -    |                | [2]   | FDC descriptor: Head number (0 or 1)                                                                            |
|         | -    |                | [1:0] | FDC descriptor: Addressed drive (0 up to 3)                                                                     |
| ffba    | -    |                | [7:4] | FDC descriptor: operation command [^TODO]                                                                       |
|         | -    |                | [3:0] | FDC descriptor: TBD                                                                                             |
| ffbb    | 1    |                | -     | FDC descriptor: sector number                                                                                   |
| ffbc    | 1    |                | -     | FDC descriptor: track number                                                                                    |
| ffbd    | 2    |                | -     | FDC descriptor: r/w buffer pointer                                                                              |
| ffbf    | 1    |                | -     | FDC descriptor: max retry for rwfs operations                                                                   |
| ....    |      |                |       |                                                                                                                 |
| ffc7    | 1    |                |       | display-related stuff                                                                                           |
| ffc8    | 1    |                |       | display-related stuff                                                                                           |
| ffc9    |      |                |       |                                                                                                                 |
| ffca    |      |                |       |                                                                                                                 |
| ffcb    |      |                |       |                                                                                                                 |
| ffcc    |      |                |       |                                                                                                                 |
| ffcd    | 1    | number of rows |       | contains configured number of displayed rows (default: 24)                                                      |
| ffce    | 1    | column         |       |                                                                                                                 |
| ffcf    | 1    |                |       | set to 0, then never changed?                                                                                   |
| ffd0    |      |                |       |                                                                                                                 |
| ffd1    |      | magenta        | [3,4] | looks like an important bitmap; bit 3 is checked a lot of time; nothing to do with colors, just a mnemonic name |
| ffd2    |      |                |       |                                                                                                                 |
| ffd3    |      |                |       |                                                                                                                 |
| ffd4    | 2    | IX             | -     | text cursor X position (?)                                                                                      |
| ffd6    | 2    | IY             | -     | linearized text cursor position                                                                                 |
| ffd7    |      |                |       |                                                                                                                 |
| ffd8    | 1    | escape status  | ?     | remember current escaping status during a putchar() Values: $00 = no ongoing escaping, $01 = ongoing escape     |
| ffd9    |      |                |       |                                                                                                                 |
| ffda    |      |                |       |                                                                                                                 |
| ....    |      |                |       |                                                                                                                 |
