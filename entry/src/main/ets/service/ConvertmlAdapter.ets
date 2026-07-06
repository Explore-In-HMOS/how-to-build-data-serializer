import { HealthRecord, ProcessedMetrics } from '../model/HealthRecord';
import { XmlPullParserAdapter, ParsedXml } from './XmlPullParserAdapter';
import { XmiSerializer } from './XmiSerializer';

/**
 * High-level conversion layer (the "convertml" concept).
 *
 * It hides the low-level XML pull parser and serializer behind two simple,
 * codelab-friendly methods:
 *   parseXmiToObject(xmi)  -> HealthRecord
 *   convertObjectToXmi(rec) -> XMI string
 *
 * Missing required fields raise an Error so the pipeline can surface a clear
 * failure status on the watch screen.
 */
export class ConvertmlAdapter {
  static parseXmiToObject(xmi: string): HealthRecord {
    const parsed: ParsedXml = XmlPullParserAdapter.parse(xmi);

    return {
      recordId: ConvertmlAdapter.requireAttribute(parsed, 'xmi:id'),
      deviceId: ConvertmlAdapter.requireAttribute(parsed, 'deviceId'),
      timestamp: ConvertmlAdapter.requireElement(parsed, 'timestamp'),
      heartRate: ConvertmlAdapter.requireElement(parsed, 'heartRate'),
      steps: Number.parseInt(ConvertmlAdapter.requireElement(parsed, 'steps'), 10),
      calories: ConvertmlAdapter.requireElement(parsed, 'calories'),
      spo2: ConvertmlAdapter.requireElement(parsed, 'spo2'),
      distanceKm: ConvertmlAdapter.requireElement(parsed, 'distanceKm'),
      sleepHours: ConvertmlAdapter.requireElement(parsed, 'sleepHours')
    };
  }

  static convertObjectToXmi(record: HealthRecord, metrics?: ProcessedMetrics): string {
    return XmiSerializer.serialize(record, metrics);
  }

  private static requireElement(parsed: ParsedXml, name: string): string {
    const value: string | undefined = parsed.elements.get(name);
    if (value === undefined) {
      throw new Error(`Missing required element: ${name}`);
    }
    return value;
  }

  private static requireAttribute(parsed: ParsedXml, name: string): string {
    const value: string | undefined = parsed.attributes.get(name);
    if (value === undefined) {
      throw new Error(`Missing required attribute: ${name}`);
    }
    return value;
  }
}
