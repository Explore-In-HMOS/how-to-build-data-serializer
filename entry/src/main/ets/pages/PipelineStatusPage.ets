import { PipelineStatus, PipelineResult, KEY_STATUS, KEY_RESULT } from '../model/PipelineState';

const STEP_ORDER: string[] = [
  PipelineStatus.Reading,
  PipelineStatus.Parsing,
  PipelineStatus.Processing,
  PipelineStatus.Serializing,
  PipelineStatus.Saving,
  PipelineStatus.Completed
];

/**
 * Shows the live pipeline status and, once complete, links to the result
 * screens. Surfaces the error message on failure.
 */
@Component
export struct PipelineStatusPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageProp(KEY_STATUS) status: string = PipelineStatus.Idle;
  @StorageProp(KEY_RESULT) result: PipelineResult = { status: PipelineStatus.Idle };

  private isCompleted(): boolean {
    return this.status === PipelineStatus.Completed;
  }

  private isFailed(): boolean {
    return this.status === PipelineStatus.Failed;
  }

  private progress(): number {
    const index: number = STEP_ORDER.indexOf(this.status);
    if (index < 0) {
      return 0;
    }
    return Math.round(((index + 1) / STEP_ORDER.length) * 100);
  }

  private statusColor(): string {
    if (this.isCompleted()) {
      return '#4CD964';
    }
    if (this.isFailed()) {
      return '#FF3B30';
    }
    return '#FFFFFF';
  }

  @Builder
  resultLink(label: string, name: string) {
    Button(label)
      .width('86%')
      .fontSize(14)
      .margin({ top: 8 })
      .onClick(() => {
        this.pathStack.pushPath({ name });
      });
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 8 }) {
          Text('Pipeline')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.status)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.statusColor())
            .margin({ top: 6 })

          if (!this.isCompleted() && !this.isFailed()) {
            LoadingProgress()
              .width(40)
              .height(40)
              .color(Color.White)
          }

          Progress({ value: this.progress(), total: 100 })
            .width('80%')
            .margin({ top: 6 })

          if (this.isFailed()) {
            Text(this.result.errorMessage ?? 'Pipeline failed')
              .fontSize(13)
              .fontColor('#FF3B30')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
          }

          if (this.isCompleted()) {
            this.resultLink('Health Record', 'HealthRecordPage')
            this.resultLink('Serialized XMI', 'SerializedOutputPage')
            this.resultLink('Buffer Demo', 'BufferDemoPage')
          }
        }
        .width('100%')
        .padding(16)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
  }
}
