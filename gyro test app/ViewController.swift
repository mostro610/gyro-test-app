//importing packages
import UIKit
import CoreMotion
import AVFoundation



class ViewController: UIViewController {
    // Labels for displaying gyro and accelerometer data
    @IBOutlet weak var gyrox: UILabel!
    @IBOutlet weak var gyroy: UILabel!
    @IBOutlet weak var gyroz: UILabel!
    @IBOutlet weak var accelx: UILabel!
    @IBOutlet weak var accely: UILabel!
    @IBOutlet weak var accelz: UILabel!
    
    @IBOutlet weak var Neigung: UILabel!
    @IBOutlet var gradmesser: UIView!
    var audioPlayer: AVAudioPlayer?
    
    // Motion manager for accessing gyro and accelerometer data
    var motion = CMMotionManager()

    
    
    // UIView to act as the rectangle
    var rectangleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRectangleView() // setup rect
        MyGyro() //aufrufen gyro funktion
        MyAccel() //aufrufen accel funktion
        
        // Initialize the audio player
        if let soundPath = Bundle.main.path(forResource: "sound001", ofType: "mp3") { //sound001 abrufen
            let soundURL = URL(fileURLWithPath: soundPath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print("Error initializing audio player: \(error.localizedDescription)")
            }
        }
    }

    

    

    func setupRectangleView() {
        // Initialize the rectangle view with a default frame
        rectangleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        rectangleView.backgroundColor = .yellow
        self.view.addSubview(rectangleView)

        // Bring the labels to the front
        self.view.bringSubviewToFront(accelx)
        self.view.bringSubviewToFront(Neigung)
        
    }

//--------Gyro--------
    func MyGyro(){
        motion.gyroUpdateInterval = 0.5 //alle 0.5 sek die Daten updaten
        motion.startGyroUpdates(to: OperationQueue.current!){ (data, error) in
            
            if let GyroData = data{ // wenn daten da sind dann weise sie der variable (let) gyroData zu
                //print(trueData)
                self.gyrox.text = "\(GyroData.rotationRate.x)" //printet uns die daten auf dem realen app screen aus
                self.gyroy.text = "\(GyroData.rotationRate.y)"
                self.gyroz.text = "\(GyroData.rotationRate.z)"
                
            }
        }
        
    }
//jjjj
    
//--------Accel--------

    func MyAccel() {
        motion.accelerometerUpdateInterval = 0.1 // wie oft soll das ganze geupdatet werden
        motion.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
            guard let self = self, let AccelData = data else { return } // wenn daten da sind dann weise sie der variable (let) accelData zu
          
            DispatchQueue.main.async {
                
                // Multiplizieren des X-Wertes der Beschleunigung mit 90 und Anzeigen auf dem Bildschirm
                let accelXMultiplied = AccelData.acceleration.x * 90
                let truncatedValue = Int(accelXMultiplied)
                self.accelx.text = "\(truncatedValue)" // Schneidet Dezimalstellen ab
                
                self.accely.text = "\(AccelData.acceleration.y)"
                self.accelz.text = "\(AccelData.acceleration.z)"
                
              
                
                // Update the rectangle size based on accelX
                self.updateRectangleSize(accelX: AccelData.acceleration.x) // funktion zum updaten der rect size abrufen
            }
        }
    }

//--------Update Rectangle >> reactive recangel--------
    
    func updateRectangleSize(accelX: Double) {
        // Normalize accelX to a value between 0 and 1
        let positivAccelX = max(min(accelX, 1.0), 0.0) //schaut das werte nicht negativ werden
        print(accelX)
        
        // Calculate scaling factor
        // The rectangle reaches its maximum size at accelX = 0.66
        let scalingFactor: CGFloat
        if positivAccelX <= 0.33 {
            // Scale up linearly until 0.66
            scalingFactor = CGFloat(positivAccelX / 0.33)
        } else {
            // Scale down linearly after 0.66
            scalingFactor = CGFloat((1.0 - positivAccelX) / (1.0 - 0.33))
        }

        // Calculate new size
        let baseSize: CGFloat = 0  // Minimum size of the rectangle
        let maxSize: CGFloat = 390   // Maximum additional size
        let newSize = baseSize + maxSize * scalingFactor

        // Update rectangle size
        rectangleView.frame.size = CGSize(width: newSize, height: 900)

        // Check if accelX is approximately 0.66 and play sound and vibrate
        if abs(accelX - 0.33) < 0.01 { //0.03 gibt die range an ab dem das vbrieren startet
            // Play sound
            audioPlayer?.play()

            // Vibrate
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    

    
    
}



