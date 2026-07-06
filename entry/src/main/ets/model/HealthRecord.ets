/**
 * A single simulated wearable health record.
 *
 * Decimal-sensitive fields (heartRate is whole, but calories, spo2, distance,
 * sleep) are kept as strings so they pass through DecimalCalculator without
 * losing precision to floating-point parsing.
 */
export interface HealthRecord {
  recordId: string;
  deviceId: string;
  timestamp: string;
  heartRate: string;
  steps: number;
  calories: string;
  spo2: string;
  distanceKm: string;
  sleepHours: string;
}

/**
 * Values derived from a HealthRecord using precise decimal arithmetic.
 */
export interface ProcessedMetrics {
  caloriesPerKm: string;
  caloriesPerStep: string;
  // Demonstrates why Decimal matters: 0.1 + 0.2 with Decimal vs plain float.
  precisionDemoDecimal: string;
  precisionDemoFloat: string;
}
