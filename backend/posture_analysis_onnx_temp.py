#!/usr/bin/env python3
import cv2
import numpy as np
import onnxruntime as ort
import sys
import json

MODEL_PATH = "best postur.onnx"

class YOLO_Pose_ONNX:
    def __init__(self, model_path):
        self.session = ort.InferenceSession(model_path)
        self.input_name = self.session.get_inputs()[0].name
        self.img_size = (640, 640)

    def predict(self, img_path):
        try:
            img_array = np.fromfile(img_path, np.uint8)
            img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)
        except:
            img = cv2.imread(img_path)
        
        if img is None:
            return None, None

        h, w = img.shape[:2]
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_resized = cv2.resize(img_rgb, self.img_size)
        input_tensor = img_resized.transpose(2, 0, 1)
        input_tensor = np.expand_dims(input_tensor, axis=0).astype(np.float32) / 255.0

        outputs = self.session.run(None, {self.input_name: input_tensor})
        output = np.transpose(np.squeeze(outputs[0]))

        if output.shape[0] == 0:
            return None, img

        scores = output[:, 4]
        best_idx = np.argmax(scores)
        if scores[best_idx] < 0.5:
            return None, img

        kpts_raw = output[best_idx, 5:]
        kpts = []
        x_scale = w / 640
        y_scale = h / 640

        for i in range(0, len(kpts_raw), 3):
            kx = kpts_raw[i] * x_scale
            ky = kpts_raw[i + 1] * y_scale
            kpts.append([kx, ky])

        return np.array(kpts), img

def analyze_posture(image_path, output_path):
    detector = YOLO_Pose_ONNX(MODEL_PATH)
    kpts, img = detector.predict(image_path)

    if kpts is None or img is None:
        return None

    burun_x = kpts[0][0]
    kulak_x = (kpts[3][0] + kpts[4][0]) / 2
    kulak_y = (kpts[3][1] + kpts[4][1]) / 2
    omuz_x = (kpts[5][0] + kpts[6][0]) / 2
    omuz_y = (kpts[5][1] + kpts[6][1]) / 2
    kalca_x = (kpts[11][0] + kpts[12][0]) / 2
    kalca_y = (kpts[11][1] + kpts[12][1]) / 2

    if burun_x > omuz_x:
        yon = "RIGHT"
        yon_katsayisi = 1
    else:
        yon = "LEFT"
        yon_katsayisi = -1

    govde_boyu = abs(kalca_y - omuz_y)
    if govde_boyu == 0:
        govde_boyu = 1

    bas_farki = (kulak_x - omuz_x) * yon_katsayisi
    bas_durumu = "NORMAL"

    if bas_farki > (govde_boyu * 0.15):
        bas_durumu = "FORWARD HEAD POSTURE"
    elif bas_farki < -(govde_boyu * 0.10):
        bas_durumu = "BACKWARD HEAD POSTURE"

    omuz_farki = (omuz_x - kalca_x) * yon_katsayisi
    kambur_durumu = "BACK ALIGNED"

    if omuz_farki > (govde_boyu * 0.12):
        kambur_durumu = "KYPHOSIS (SLOUCHING)"

    genel_yorum = "HEALTHY POSTURE"
    if "POSTURE" in bas_durumu or "KYPHOSIS" in kambur_durumu:
        genel_yorum = "CONSULT A DOCTOR"

    # Draw visualization
    cv2.line(img, (int(kulak_x), int(kulak_y)), (int(omuz_x), int(omuz_y)), (255, 0, 255), 3)
    cv2.line(img, (int(omuz_x), int(omuz_y)), (int(kalca_x), int(kalca_y)), (255, 0, 255), 3)
    cv2.imwrite(output_path, img)

    # Return structured result (convert numpy float32 to Python float for JSON)
    return {
        "success": True,
        "direction": yon,
        "headPosture": {
            "status": bas_durumu,
            "deviation": float(abs(bas_farki / govde_boyu * 50)),
            "severity": "critical" if "FORWARD" in bas_durumu and abs(bas_farki / govde_boyu) > 0.15 else "moderate" if "POSTURE" in bas_durumu else "normal"
        },
        "backPosture": {
            "status": kambur_durumu,
            "tilt": float(abs(omuz_farki / govde_boyu * 50)),
            "severity": "critical" if "KYPHOSIS" in kambur_durumu else "normal"
        },
        "overallStatus": genel_yorum,
        "overallSeverity": "critical" if genel_yorum == "CONSULT A DOCTOR" else "normal",
        "consultDoctor": genel_yorum == "CONSULT A DOCTOR",
        "recommendations": [
            f"✅ Direction: {yon}",
            f"💡 Neck: {bas_durumu}",
            f"💪 Back: {kambur_durumu}",
            f"🏥 Result: {genel_yorum}"
        ],
        "score": 95 if genel_yorum == "HEALTHY POSTURE" else 75,
        "keypoints": []
    }

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python posture_analysis.py <input_image> <output_image>")
        sys.exit(1)
    
    result = analyze_posture(sys.argv[1], sys.argv[2])
    if result:
        print(json.dumps(result))
        sys.exit(0)
    else:
        print(json.dumps({"error": "Analysis failed"}))
        sys.exit(1)
