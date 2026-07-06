/**
 * Compact binary representation of the most important health metrics.
 *
 * Layout encoded by FastBufferAdapter:
 *   [heartRate:int16][steps:int32][calories:float32][spo2:int8]
 *
 * Total size: 2 + 4 + 4 + 1 = 11 bytes.
 */
export interface HealthMetricPacket {
  heartRate: number;
  steps: number;
  calories: number;
  spo2: number;
}

export const PACKET_SIZE: number = 11;
