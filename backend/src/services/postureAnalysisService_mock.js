/**
 * Mock Posture Analysis Service - Python ONNX kodlarına göre sonuçlar
 */
export class PostureAnalysisService {
  async analyzePosture(imagePath) {
    // Python ONNX kodundaki senaryolar
    const scenarios = [
      {
        direction: 'FRONT',
        headPosture: { status: 'NORMAL', deviation: 0, severity: 'normal' },
        backPosture: { status: 'BACK ALIGNED', tilt: 0, severity: 'normal' },
        overallStatus: 'HEALTHY POSTURE',
        overallSeverity: 'normal',
        consultDoctor: false,
        recommendations: ['✅ Your posture is excellent!', '💪 Continue maintaining proper alignment.', '🏃 Keep up the good work!'],
        score: 94
      },
      {
        direction: 'LEFT',
        headPosture: { status: 'FORWARD HEAD POSTURE', deviation: 7.5, severity: 'moderate' },
        backPosture: { status: 'BACK ALIGNED', tilt: 0, severity: 'normal' },
        overallStatus: 'CONSULT A DOCTOR',
        overallSeverity: 'moderate',
        consultDoctor: true,
        recommendations: ['⚠️ Forward head posture detected.', '💡 Adjust screen height to eye level.', '🏥 Consider physiotherapy.', '📱 Reduce phone usage time.'],
        score: 72
      },
      {
        direction: 'RIGHT',
        headPosture: { status: 'FORWARD HEAD POSTURE', deviation: 9.2, severity: 'critical' },
        backPosture: { status: 'KYPHOSIS (SLOUCHING)', tilt: 12.3, severity: 'critical' },
        overallStatus: 'CONSULT A DOCTOR',
        overallSeverity: 'critical',
        consultDoctor: true,
        recommendations: ['🚨 CONSULT A DOCTOR IMMEDIATELY!', '⚠️ Severe forward head posture (18.5°).', '⚠️ Severe slouching detected.', '💊 Physical therapy required.', '🏥 Urgent medical evaluation needed.'],
        score: 68
      },
      {
        direction: 'FRONT',
        headPosture: { status: 'NORMAL', deviation: 0.8, severity: 'normal' },
        backPosture: { status: 'BACK ALIGNED', tilt: 0, severity: 'normal' },
        overallStatus: 'HEALTHY POSTURE',
        overallSeverity: 'normal',
        consultDoctor: false,
        recommendations: ['✅ Excellent posture alignment!', '💪 Keep maintaining proper posture.', '🏃 Continue your routine.'],
        score: 91
      },
      {
        direction: 'LEFT',
        headPosture: { status: 'SLIGHT FORWARD HEAD', deviation: 4.2, severity: 'mild' },
        backPosture: { status: 'MILD KYPHOSIS', tilt: 6.8, severity: 'moderate' },
        overallStatus: 'CONSULT A DOCTOR',
        overallSeverity: 'moderate',
        consultDoctor: true,
        recommendations: ['💡 Minor head forward detected (8.3°).', '⚠️ Mild slouching detected.', '💪 Focus on back strengthening exercises.', '🏥 Monitor your posture regularly.'],
        score: 76
      },
      {
        direction: 'RIGHT',
        headPosture: { status: 'BACKWARD HEAD POSTURE', deviation: 5.6, severity: 'moderate' },
        backPosture: { status: 'KYPHOSIS (SLOUCHING)', tilt: 14.5, severity: 'critical' },
        overallStatus: 'CONSULT A DOCTOR',
        overallSeverity: 'critical',
        consultDoctor: true,
        recommendations: ['🚨 Abnormal backward head position!', '⚠️ Severe slouching detected (14.5cm).', '💊 Physical therapy strongly recommended.', '🏥 Medical consultation needed.'],
        score: 65
      },
      {
        direction: 'FRONT',
        headPosture: { status: 'NORMAL', deviation: 0.5, severity: 'normal' },
        backPosture: { status: 'MILD KYPHOSIS', tilt: 7.2, severity: 'moderate' },
        overallStatus: 'CONSULT A DOCTOR',
        overallSeverity: 'moderate',
        consultDoctor: true,
        recommendations: ['✅ Head position is good.', '⚠️ Mild slouching detected in upper back.', '💪 Back strengthening exercises recommended.', '🏥 Monitor condition regularly.'],
        score: 79
      }
    ];

    // Random seçim
    const scenario = scenarios[Math.floor(Math.random() * scenarios.length)];
    
    console.log('🎲 Mock posture analysis - Selected scenario:', scenario.overallStatus);

    return {
      success: true,
      ...scenario,
      keypoints: [],
      imagePath: imagePath
    };
  }
}

export default new PostureAnalysisService();
