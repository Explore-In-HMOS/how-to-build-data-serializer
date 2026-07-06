import { PipelineStatus, PipelineResult, KEY_RESULT } from '../model/PipelineState';
import { HealthRecord, ProcessedMetrics } from '../model/HealthRecord';

/** One serialized field shown as a readable key/value row. */
interface XmiField {
  key: string;
  value: string;
}

/**
 * Shows the serialized result as readable key/value lines and the local save
 * status. The lines are built from the same record/metrics that were written
 * into the XMI, so the screen mirrors the serialized output without the dense
 * single-line XML markup.
 */
@Component
export struct SerializedOutputPage {
  @StorageProp(KEY_RESULT) result: PipelineResult = { status: PipelineStatus.Idle };

  /** Flatten the record and processed metrics into ordered key/value rows. */
  private fields(): XmiField[] {
    const rows: XmiField[] = [];
    const record: HealthRecord | undefined = this.result.record;
    if (record !== undefined) {
      rows.push({ key: 'recordId', value: record.recordId });
      rows.push({ key: 'deviceId', value: record.deviceId });
      rows.push({ key: 'timestamp', value: record.timestamp });
      rows.push({ key: 'heartRate', value: record.heartRate });
      rows.push({ key: 'steps', value: record.steps.toString() });
      rows.push({ key: 'calories', value: record.calories });
      rows.push({ key: 'spo2', value: record.spo2 });
      rows.push({ key: 'distanceKm', value: record.distanceKm });
      rows.push({ key: 'sleepHours', value: record.sleepHours });
    }
    const metrics: ProcessedMetrics | undefined = this.result.metrics;
    if (metrics !== undefined) {
      rows.push({ key: 'caloriesPerKm', value: metrics.caloriesPerKm });
      rows.push({ key: 'caloriesPerStep', value: metrics.caloriesPerStep });
    }
    return rows;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 6 }) {
          Text('Serialized XMI')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CD964')

          Text(this.result.savedAt !== undefined ? `Saved locally: ${this.result.savedAt}` : 'Not saved')
            .fontSize(11)
            .fontColor('#AAAAAA')
            .textAlign(TextAlign.Center)

          if (this.fields().length === 0) {
            Text('No output available')
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 8 })
          } else {
            Column({ space: 4 }) {
              ForEach(this.fields(), (field: XmiField) => {
                Row() {
                  Text(`${field.key}:`)
                    .fontSize(12)
                    .fontColor('#AAAAAA')
                  Blank()
                  Text(field.value)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .textAlign(TextAlign.End)
                }
                .width('100%')
              }, (field: XmiField) => field.key)
            }
            .width('100%')
            .backgroundColor('#111111')
            .padding(10)
            .borderRadius(8)
            .margin({ top: 4 })

            if (this.result.serializedXmi !== undefined) {
              Text('Generated XMI')
                .fontSize(13)
                .fontColor('#4CD964')
                .margin({ top: 10, bottom: 2 })

              Text(this.result.serializedXmi)
                .fontSize(10)
                .fontColor('#DDDDDD')
                .fontFamily('monospace')
                .width('100%')
                .backgroundColor('#111111')
                .padding(10)
                .borderRadius(8)
            }
          }
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
  }
}
