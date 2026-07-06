/**
 * Simulated incoming health data.
 *
 * This is local mock XMI/XML, NOT real sensor data. There is no Bluetooth,
 * Health Kit, Wear Engine, network, or device permission involved. The string
 * below stands in for a record that a wearable might receive for serialization.
 */
export const MOCK_INCOMING_XMI: string = `<?xml version="1.0" encoding="UTF-8"?>
<healthRecord xmi:id="record-001" deviceId="watch-demo-001">
<timestamp>2026-06-09T10:30:00Z</timestamp>
<heartRate>78</heartRate>
<steps>6240</steps>
<calories>312.45</calories>
<spo2>98.2</spo2>
<distanceKm>4.37</distanceKm>
<sleepHours>7.25</sleepHours>
</healthRecord>`;
