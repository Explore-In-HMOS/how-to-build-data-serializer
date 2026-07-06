import { common } from '@kit.AbilityKit';
import { PipelineStatus, PipelineResult, KEY_STATUS, KEY_RESULT } from '../model/PipelineState';
import { HealthDataPipeline } from '../service/HealthDataPipeline';
import { PipelineStatusPage } from './PipelineStatusPage';
import { HealthRecordPage } from './HealthRecordPage';
import { SerializedOutputPage } from './SerializedOutputPage';
import { BufferDemoPage } from './BufferDemoPage';

/**
 * Home screen and Navigation host. Explains the codelab, makes clear the data
 * is simulated, and starts the serialization pipeline. The shared NavPathStack
 * is provided to every destination page through @Provide / @Consume.
 */
@Entry
@Component
struct Index {
  @StorageLink(KEY_STATUS) status: string = PipelineStatus.Idle;
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();

  private async startPipeline(): Promise<void> {
    AppStorage.setOrCreate<string>(KEY_STATUS, PipelineStatus.Reading);
    AppStorage.setOrCreate<PipelineResult>(KEY_RESULT, { status: PipelineStatus.Reading });
    this.pathStack.pushPath({ name: 'PipelineStatusPage' });

    const context = this.getUIContext().getHostContext() as common.Context;
    const result: PipelineResult = await HealthDataPipeline.run(context, (s: PipelineStatus) => {
      AppStorage.setOrCreate<string>(KEY_STATUS, s);
    });
    AppStorage.setOrCreate<PipelineResult>(KEY_RESULT, result);
  }

  /** Maps a pushed route name to its destination page. */
  @Builder
  pageMap(name: string) {
    if (name === 'PipelineStatusPage') {
      PipelineStatusPage()
    } else if (name === 'HealthRecordPage') {
      HealthRecordPage()
    } else if (name === 'SerializedOutputPage') {
      SerializedOutputPage()
    } else if (name === 'BufferDemoPage') {
      BufferDemoPage()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 10 }) {
        Text('Data Serializer')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('Wearable health data pipeline')
          .fontSize(13)
          .fontColor('#AAAAAA')
          .textAlign(TextAlign.Center)

        Text('Local Sample Data')
          .fontSize(12)
          .fontColor('#4CD964')
          .margin({ top: 2 })

        Button('Start Pipeline')
          .width('80%')
          .fontSize(16)
          .margin({ top: 14 })
          .onClick(() => {
            this.startPipeline();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.pageMap)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
