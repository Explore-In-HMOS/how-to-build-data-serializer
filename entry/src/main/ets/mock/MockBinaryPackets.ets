import { HealthMetricPacket } from '../model/HealthMetricPacket';

/**
 * Mock values for the compact binary health packet demo.
 *
 * These are simulated metrics, not readings from a real device. The pipeline
 * derives the same values from the parsed record, but this constant lets the
 * buffer demo run on its own as well.
 */
export const MOCK_PACKET: HealthMetricPacket = {
  heartRate: 78,
  steps: 6240,
  calories: 312.45,
  spo2: 98
};
