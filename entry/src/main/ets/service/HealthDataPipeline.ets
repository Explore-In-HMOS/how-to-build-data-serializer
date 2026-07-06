import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { HealthRecord, ProcessedMetrics } from '../model/HealthRecord';
import { HealthMetricPacket } from '../model/HealthMetricPacket';
import { PipelineStatus, PipelineResult } from '../model/PipelineState';
import { MOCK_INCOMING_XMI } from '../mock/MockHealthRecords';
import { StreamProcessor, StreamReport } from './StreamProcessor';
import { ConvertmlAdapter } from './ConvertmlAdapter';
import { FastBufferAdapter } from './FastBufferAdapter';
import { DecimalCalculator } from './DecimalCalculator';
import { LocalStorageService } from './LocalStorageService';
import { Logger } from '../utils/Logger';

/**
 * Orchestrates the full simulated serialization pipeline:
 *   stream -> parse (convertml/xml) -> fastbuffer -> decimal -> serialize -> save
 *
 * Status updates are pushed through onStatus so the watch UI can show each
 * step. Any failure is caught and returned as a Failed result with a message.
 */
export class HealthDataPipeline {
  private static readonly CHUNK_SIZE: number = 32;

  static async run(
    context: common.Context,
    onStatus: (status: PipelineStatus) => void
  ): Promise<PipelineResult> {
    try {
      onStatus(PipelineStatus.Reading);
      const stream: StreamReport =
        await StreamProcessor.readInChunks(MOCK_INCOMING_XMI, HealthDataPipeline.CHUNK_SIZE);
      Logger.info('Pipeline', `read ${stream.chunks} chunks (${stream.bytes} bytes)`);

      onStatus(PipelineStatus.Parsing);
      const record: HealthRecord = ConvertmlAdapter.parseXmiToObject(stream.output);

      onStatus(PipelineStatus.Processing);
      const packet: HealthMetricPacket = HealthDataPipeline.buildBufferDemo(record);
      const encoded: buffer.Buffer = FastBufferAdapter.encodePacket(packet);
      const decoded: HealthMetricPacket = FastBufferAdapter.decodePacket(encoded);
      const metrics: ProcessedMetrics = HealthDataPipeline.computeMetrics(record);

      onStatus(PipelineStatus.Serializing);
      const xmi: string = ConvertmlAdapter.convertObjectToXmi(record, metrics);

      onStatus(PipelineStatus.Saving);
      const savedAt: string =
        await LocalStorageService.save(context, record, xmi, PipelineStatus.Completed);

      onStatus(PipelineStatus.Completed);
      return {
        status: PipelineStatus.Completed,
        record,
        metrics,
        packet: decoded,
        packetBytes: encoded.length,
        serializedXmi: xmi,
        savedAt
      };
    } catch (e) {
      const message: string = e instanceof Error ? e.message : 'Unknown pipeline error';
      Logger.error('Pipeline', message);
      onStatus(PipelineStatus.Failed);
      return { status: PipelineStatus.Failed, errorMessage: message };
    }
  }

  private static buildBufferDemo(record: HealthRecord): HealthMetricPacket {
    return {
      heartRate: Number.parseInt(record.heartRate, 10),
      steps: record.steps,
      calories: Number.parseFloat(record.calories),
      spo2: Math.round(Number.parseFloat(record.spo2))
    };
  }

  private static computeMetrics(record: HealthRecord): ProcessedMetrics {
    return {
      caloriesPerKm: DecimalCalculator.divide(record.calories, record.distanceKm, 2),
      caloriesPerStep: DecimalCalculator.divide(record.calories, record.steps.toString(), 4),
      precisionDemoDecimal: DecimalCalculator.precisionDemoDecimal(),
      precisionDemoFloat: DecimalCalculator.precisionDemoFloat()
    };
  }
}
