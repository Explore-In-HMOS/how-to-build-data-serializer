import { PipelineResult, KEY_RESULT } from '../model/PipelineState';
import { HealthMetricPacket } from '../model/HealthMetricPacket';
import { FastBufferAdapter } from '../service/FastBufferAdapter';
import { MOCK_PACKET } from '../mock/MockBinaryPackets';
import { buffer } from '@kit.ArkTS';

const EMPTY_PACKET: HealthMetricPacket = { heartRate: 0, steps: 0, calories: 0, spo2: 0 };

/**
 * Shows the compact binary packet: its encoded size and the decoded values.
 */
@Component
export struct BufferDemoPage {
  @State packet: HealthMetricPacket = EMPTY_PACKET;
  @State packetBytes: number = 0;
  @State hasData: boolean = false;

  aboutToAppear(): void {
    const result: PipelineResult | undefined = AppStorage.get<PipelineResult>(KEY_RESULT);
    if (result !== undefined && result.packet !== undefined) {
      this.packet = result.packet;
      this.packetBytes = result.packetBytes ?? 0;
      this.hasData = true;
      return;
    }
    // Opened standalone: run the encode/decode round trip on the mock packet.
    const encoded: buffer.Buffer = FastBufferAdapter.encodePacket(MOCK_PACKET);
    this.packet = FastBufferAdapter.decodePacket(encoded);
    this.packetBytes = encoded.length;
    this.hasData = true;
  }

  @Builder
  row(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#AAAAAA')
      Blank()
      Text(value)
        .fontSize(15)
        .fontColor(Color.White)
    }
    .width('70%')
    .padding({ top: 5, bottom: 5 })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 2 }) {
          Text('Mock Binary Packet')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CD964')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 6 })
            .padding({ top: 10 })

          this.row('Packet size', `${this.packetBytes} bytes`)

          if (this.hasData) {
            Divider().color('#333333').margin({ top: 6, bottom: 4 })
            Text('Decoded values')
              .fontSize(13)
              .fontColor('#4CD964')
              .margin({ bottom: 2 })
            this.row('Heart Rate', `${this.packet.heartRate} bpm`)
            this.row('Steps', this.packet.steps.toString())
            this.row('Calories', `${this.packet.calories.toFixed(2)} kcal`)
            this.row('SpO2', `${this.packet.spo2} %`)
          } else {
            Text('No packet available')
              .fontSize(14)
              .fontColor('#AAAAAA')
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
