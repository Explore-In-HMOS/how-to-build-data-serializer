import { buffer } from '@kit.ArkTS';
import { HealthMetricPacket, PACKET_SIZE } from '../model/HealthMetricPacket';

/**
 * High-performance binary buffer operations (the "fastbuffer" concept).
 *
 * Wraps the official @kit.ArkTS buffer module to encode/decode a compact
 * mock health packet. This shows why wearables use packed binary buffers to
 * exchange metrics instead of verbose text.
 *
 * Packet layout (11 bytes, big-endian):
 *   offset 0  int16   heartRate
 *   offset 2  int32   steps
 *   offset 6  float32 calories
 *   offset 10 int8    spo2
 */
export class FastBufferAdapter {
  static encodePacket(packet: HealthMetricPacket): buffer.Buffer {
    const buf: buffer.Buffer = buffer.alloc(PACKET_SIZE);
    buf.writeInt16BE(packet.heartRate, 0);
    buf.writeInt32BE(packet.steps, 2);
    buf.writeFloatBE(packet.calories, 6);
    buf.writeInt8(packet.spo2, 10);
    return buf;
  }

  static decodePacket(buf: buffer.Buffer): HealthMetricPacket {
    return {
      heartRate: buf.readInt16BE(0),
      steps: buf.readInt32BE(2),
      calories: buf.readFloatBE(6),
      spo2: buf.readInt8(10)
    };
  }

  /** Short-string round trip, demonstrating string writes/reads in a buffer. */
  static encodeString(text: string): buffer.Buffer {
    return buffer.from(text, 'utf-8');
  }

  static decodeString(buf: buffer.Buffer): string {
    return buf.toString('utf-8');
  }
}
