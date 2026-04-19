# Ethernet packet offset reference

Byte indexes for slicing raw frame data starting at the Ethernet header (Layer 2). Runtime capture uses [gopacket](https://github.com/google/gopacket); this table is a manual reference for debugging and documentation.

## Packet header map

| Component | Byte index | Size (bytes) | Description |
| :--- | :--- | :--- | :--- |
| **MAC destination** | `0:6` | 6 | Destination hardware address |
| **MAC source** | `6:12` | 6 | Source hardware address |
| **EtherType** | `12:14` | 2 | Protocol type (IPv4 is `0x0800`) |
| **IP header size** | `14` | 1 | `(byte & 0x0F) * 4` |
| **Source IP** | `26:30` | 4 | Sender IP address |
| **Destination IP** | `30:34` | 4 | Receiver IP address |
| **Source port** | `34:36` | 2 | Sender TCP port |
| **Destination port** | `36:38` | 2 | Receiver TCP port |
| **Sequence number** | `38:42` | 4 | TCP sequence number |
| **TCP header size** | `46` | 1 | `(byte >> 4) * 4` |
| **Flags** | `47` | 1 | ACK, PSH, FIN, SYN bits |

## Slicing logic

IP and TCP headers may include options, so sizes are dynamic. Payload (L7) start:

**Payload start** = `14` (Ethernet) + `IP_header_size` + `TCP_header_size`
