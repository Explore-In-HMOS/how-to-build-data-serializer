import { PipelineResult, KEY_RESULT } from '../model/PipelineState';
import { HealthRecord, ProcessedMetrics } from '../model/HealthRecord';

const EMPTY_RECORD: HealthRecord = {
  recordId: '', deviceId: '', timestamp: '', heartRate: '',
  steps: 0, calories: '', spo2: '', distanceKm: '', sleepHours: ''
};

const EMPTY_METRICS: ProcessedMetrics = {
  caloriesPerKm: '', caloriesPerStep: '', precisionDemoDecimal: '', precisionDemoFloat: ''
};

/**
 * Shows the parsed health record and the decimal-processed metrics.
 */
@Component
export struct HealthRecordPage {
  @State record: HealthRecord = EMPTY_RECORD;
  @State metrics: ProcessedMetrics = EMPTY_METRICS;
  @State hasData: boolean = false;

  aboutToAppear(): void {
    const result: PipelineResult | undefined = AppStorage.get<PipelineResult>(KEY_RESULT);
    if (result !== undefined && result.record !== undefined) {
      this.record = result.record;
      this.hasData = true;
      if (result.metrics !== undefined) {
        this.metrics = result.metrics;
      }
    }
  }

  @Builder
  metric(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#AAAAAA')
      Blank()
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
    }
    .width('100%')
    .padding({ top: 5, bottom: 5 })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 2 }) {
          Text('Health Record')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CD964')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 6 })

          if (this.hasData) {
            this.metric('Heart Rate', `${this.record.heartRate} bpm`)
            this.metric('Steps', this.record.steps.toString())
            this.metric('Calories', `${this.record.calories} kcal`)
            this.metric('SpO2', `${this.record.spo2} %`)
            this.metric('Distance', `${this.record.distanceKm} km`)
            this.metric('Sleep', `${this.record.sleepHours} h`)
            this.metric('Time', this.record.timestamp)

            Divider().color('#333333').margin({ top: 8, bottom: 4 })
            Text('Decimal Metrics')
              .fontSize(13)
              .fontColor('#4CD964')
              .margin({ bottom: 2 })
            this.metric('Cal / km', this.metrics.caloriesPerKm)
            this.metric('Cal / step', this.metrics.caloriesPerStep)
            this.metric('0.1 + 0.2 (Decimal)', this.metrics.precisionDemoDecimal)
            this.metric('0.1 + 0.2 (float)', this.metrics.precisionDemoFloat)
          } else {
            Text('No record available')
              .fontSize(14)
              .fontColor('#AAAAAA')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 26, bottom: 48 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
  }
}
