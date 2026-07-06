import { HealthRecord, ProcessedMetrics } from './HealthRecord';
import { HealthMetricPacket } from './HealthMetricPacket';

/**
 * Status of the simulated serialization pipeline. Shown on the watch screen.
 */
export enum PipelineStatus {
  Idle = 'Idle',
  Reading = 'Reading',
  Parsing = 'Parsing',
  Processing = 'Processing',
  Serializing = 'Serializing',
  Saving = 'Saving',
  Completed = 'Completed',
  Failed = 'Failed'
}

/**
 * Full result of one pipeline run, shared with the UI through AppStorage.
 */
export interface PipelineResult {
  status: PipelineStatus;
  record?: HealthRecord;
  metrics?: ProcessedMetrics;
  packet?: HealthMetricPacket;
  packetBytes?: number;
  serializedXmi?: string;
  savedAt?: string;
  errorMessage?: string;
}

// AppStorage keys shared between the pipeline and the pages.
export const KEY_STATUS: string = 'pipeline_status';
export const KEY_RESULT: string = 'pipeline_result';
