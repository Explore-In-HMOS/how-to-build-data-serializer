import { xml } from '@kit.ArkTS';
import { HealthRecord, ProcessedMetrics } from '../model/HealthRecord';

/**
 * Serializes a HealthRecord back into an XMI/XML string.
 *
 * Uses the official @kit.ArkTS xml.XmlSerializer to write the document
 * (declaration, elements, attributes, text). The serializer writes UTF-8
 * bytes into an ArrayBuffer; since the codelab data is ASCII we read the
 * bytes back with a small local decoder that stops at the first unused byte.
 */
export class XmiSerializer {
  private static readonly BUFFER_SIZE: number = 2048;

  static serialize(record: HealthRecord, metrics?: ProcessedMetrics): string {
    const buffer: ArrayBuffer = new ArrayBuffer(XmiSerializer.BUFFER_SIZE);
    const serializer: xml.XmlSerializer = new xml.XmlSerializer(buffer, 'UTF-8');

    serializer.setDeclaration();
    serializer.startElement('healthRecord');
    serializer.setAttributes('xmi:id', record.recordId);
    serializer.setAttributes('deviceId', record.deviceId);

    XmiSerializer.writeChild(serializer, 'timestamp', record.timestamp);
    XmiSerializer.writeChild(serializer, 'heartRate', record.heartRate);
    XmiSerializer.writeChild(serializer, 'steps', record.steps.toString());
    XmiSerializer.writeChild(serializer, 'calories', record.calories);
    XmiSerializer.writeChild(serializer, 'spo2', record.spo2);
    XmiSerializer.writeChild(serializer, 'distanceKm', record.distanceKm);
    XmiSerializer.writeChild(serializer, 'sleepHours', record.sleepHours);

    if (metrics !== undefined) {
      XmiSerializer.writeMetrics(serializer, metrics);
    }

    serializer.endElement();

    return XmiSerializer.decodeAscii(buffer);
  }

  /** Write the Decimal-processed metrics as a nested <processedMetrics> block. */
  private static writeMetrics(serializer: xml.XmlSerializer, metrics: ProcessedMetrics): void {
    serializer.startElement('processedMetrics');
    XmiSerializer.writeChild(serializer, 'caloriesPerKm', metrics.caloriesPerKm);
    XmiSerializer.writeChild(serializer, 'caloriesPerStep', metrics.caloriesPerStep);
    serializer.endElement();
  }

  private static writeChild(serializer: xml.XmlSerializer, name: string, value: string): void {
    serializer.startElement(name);
    serializer.setText(value);
    serializer.endElement();
  }

  private static decodeAscii(buffer: ArrayBuffer): string {
    const view: Uint8Array = new Uint8Array(buffer);
    let result: string = '';
    for (let i = 0; i < view.length; i++) {
      const byte: number = view[i];
      if (byte === 0) {
        break;
      }
      result += String.fromCharCode(byte);
    }
    return result;
  }
}
