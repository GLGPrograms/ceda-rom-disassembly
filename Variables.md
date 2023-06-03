# Variables

# Constants
| address | size | value | description                    |
| ------- | ---- | ----- | ------------------------------ |
| c86f    | 1    | $0d   | CRTC R10 default configuration |

# Default bank

| address | size | name           | bits  | description                                                                                                                  |
| ------- | ---- | -------------- | ----- | ---------------------------------------------------------------------------------------------------------------------------- |
| ffb7    | -    |                | [3:0] | FDC descriptor: Bit flags of already accessed floppy drives                                                                  |
| ffb8    | -    |                | [1:0] | FDC descriptor: Bytes per sector "factor" (bps = 0x80 << f) [^TODO2]                                                         |
| ffb9    | -    |                | [2]   | FDC descriptor: Head number (0 or 1)                                                                                         |
|         | -    |                | [1:0] | FDC descriptor: Addressed drive (0 up to 3)                                                                                  |
| ffba    | -    |                | [7:4] | FDC descriptor: operation command [^TODO]                                                                                    |
|         | -    |                | [3:0] | FDC descriptor: TBD                                                                                                          |
| ffbb    | 1    |                | -     | FDC descriptor: sector number                                                                                                |
| ffbc    | 1    |                | -     | FDC descriptor: track number                                                                                                 |
| ffbd    | 2    |                | -     | FDC descriptor: r/w buffer pointer                                                                                           |
| ffbf    | 1    |                | -     | FDC descriptor: max retry for rwfs operations                                                                                |
| ....    |      |                |       |                                                                                                                              |
| ffc7    | 1    |                |       | display-related stuff                                                                                                        |
| ffc8    | 1    |                |       | display-related stuff                                                                                                        |
| ffc9    | 1    |                |       | display-related stuff                                                                                                        |
| ffca    | 1    | current_column |       | display column where the cursor is positioned                                                                                |
| ffcb    | 1    | current_row    |       | display row where the cursor is positioned                                                                                   |
| ffcc    |      |                |       |                                                                                                                              |
| ffcd    | 1    | number of rows |       | contains configured number of displayed rows (default: 24)                                                                   |
| ffce    | 1    | column         |       |                                                                                                                              |
| ffcf    | 1    |                |       | set to 0, then never changed?                                                                                                |
| ffd0    | 1    |                |       | something which has to do with display columns (see $ffcb and $ffca too)                                                     |
| ffd1    |      | _magenta_      | [3,4] | current character [text attribute](https://github.com/GLGPrograms/ceda-home/blob/main/pages/video.md#attribute-video-memory) |
| ffd2    |      |                |       |                                                                                                                              |
| ffd3    | 1    | crtc_r10_mem   | [5:6] | memory backup of CRTC R10 content                                                                                            |
| ffd4    | 2    | IX             | -     | text cursor X position (?)                                                                                                   |
| ffd6    | 2    | IY             | -     | linearized text cursor position                                                                                              |
| ffd7    |      |                |       |                                                                                                                              |
| ffd8    | 1    | escaped_char   | ?     | remember current escaping char during a putchar()                                                                            |
|         |      | "              |       | Values: $00 = no ongoing escaping, $01 = ongoing escape, any other: current char to be escaped?                              |
| ffd9    | 1    | _blues_        |       | index of array at $ffda ?                                                                                                    |
| ffda    | 3(+) | _cyan_         |       |                                                                                                                              |
| ....    |      |                |       |                                                                                                                              |
