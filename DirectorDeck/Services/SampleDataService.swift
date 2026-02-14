import Foundation
import SwiftData
import UIKit

struct SampleDataService {
    
    static func loadIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Project>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        createTheLastLight(context: context)
    }
    
    private static func createTheLastLight(context: ModelContext) {
        // MARK: - Project
        let project = Project(
            name: "The Last Light",
            projectDescription: "A contemplative short film about a lighthouse keeper's final night before automation replaces him. 12 minutes, shot on location in Maine."
        )
        context.insert(project)
        
        // MARK: - Creative Brief
        let brief = CreativeBrief(
            title: "Creative Vision — The Last Light",
            content: """
            THE LAST LIGHT — Creative Brief
            ================================
            
            LOGLINE
            A retiring lighthouse keeper spends his final night tending the light, reflecting on decades of solitude, purpose, and the sea that shaped him — before an automated system renders him obsolete.
            
            TONE & STYLE
            Contemplative, melancholic, visually poetic. Think Terrence Malick meets Robert Eggers. Natural light wherever possible, with the lighthouse beam as a recurring visual motif — sweeping through fog, illuminating fragments of memory.
            
            COLOR PALETTE
            Cool blues and slate grays dominate, punctuated by warm amber from the lighthouse lamp and lantern light. The contrast between cold exterior and warm interior mirrors the keeper's emotional journey.
            
            SOUND DESIGN
            The ocean is ever-present. Waves, wind, foghorns, the mechanical rhythm of the light mechanism. Minimal score — solo cello or piano in key moments. Silence is as important as sound.
            
            VISUAL APPROACH
            - Handheld for intimate moments (keeper's hands, face, routine)
            - Locked-off wide shots for landscape/seascape establishing shots
            - Slow tracking shots through the lighthouse interior
            - Golden hour and blue hour shooting for exteriors
            - Practical lighting: lanterns, the lighthouse beam, firelight
            
            KEY THEMES
            - Obsolescence vs. purpose
            - Solitude as both burden and gift
            - The relationship between humans and the machines they tend
            - Legacy — what remains when we leave
            
            REFERENCES
            - "The Lighthouse" (Eggers, 2019) — texture, isolation
            - "Nomadland" (Zhao, 2020) — contemplative pacing
            - "The Old Man and the Sea" (Hemingway) — dignity in routine
            - Andrew Wyeth paintings — coastal New England mood
            
            RUNTIME TARGET: 12-14 minutes
            SHOOTING DAYS: 3 (2 exterior, 1 interior)
            FORMAT: 4K, 2.39:1 anamorphic
            CAMERA: ARRI Alexa Mini LF + Cooke Anamorphic/i primes
            """,
            project: project
        )
        context.insert(brief)
        
        // MARK: - Interview Subjects & Questions
        let subject1 = InterviewSubject(
            name: "Thomas Hargrove",
            role: "Retired Lighthouse Keeper, Portland Head Light",
            notes: "78 years old. Kept the Portland Head Light for 31 years. Retired in 2004 when it was fully automated. Lives in Cape Elizabeth. Very willing to talk but gets emotional about the transition.",
            project: project
        )
        context.insert(subject1)
        
        let questions1: [(String, String, Bool)] = [
            ("What did a typical day look like for you at the lighthouse?", "Start with routine to ease him in. Let him paint the picture.", true),
            ("Can you describe the moment you first realized the light would be automated?", "This is the emotional core. Give him space.", true),
            ("What does the sound of the foghorn mean to you now, hearing it from your house?", "He lives close enough to still hear it. Powerful sensory detail.", false),
            ("Was there ever a night where you felt the light truly saved someone?", "He's mentioned a 1987 storm before — follow up on this.", false),
            ("How do you explain what you did to people who've never seen a working lighthouse?", "Gets at the theme of obsolescence and understanding.", false),
            ("If you could spend one more night in the lamp room, what would you do?", "Closing question. Mirror our film's premise.", false),
        ]
        
        for (i, q) in questions1.enumerated() {
            let question = InterviewQuestion(text: q.0, notes: q.1, orderIndex: i, subject: subject1)
            question.isAsked = q.2
            context.insert(question)
        }
        
        // MARK: - Storyboard Cards
        let storyboardData: [(String, String, String, String)] = [
            ("Opening — Dawn at Sea", "Wide establishing shot. First light on the horizon, lighthouse silhouetted against pre-dawn sky. The beam still rotating.", "Ultra Wide", "8s"),
            ("The Keeper Wakes", "Interior. Close-up of weathered hands reaching for a wind-up alarm clock. Warm lantern light. The bed is simple, military-neat.", "Close-Up", "4s"),
            ("Morning Routine", "Montage: polishing the lens, checking the log book, brewing coffee on a camp stove. Methodical, practiced movements.", "Various", "30s"),
            ("The Letter", "Medium shot. The keeper reads an official letter at his small desk. We see the words 'automated system' and 'effective immediately.' His face doesn't change.", "Medium", "6s"),
            ("Climbing the Tower", "Low angle tracking shot following the keeper up the spiral staircase. His hand trails along the worn railing. 147 steps.", "Low Angle Track", "12s"),
            ("The Lamp Room — Golden Hour", "The keeper tends the Fresnel lens as golden light floods through the glass. He's bathed in prismatic light. The most beautiful shot in the film.", "Wide + Details", "15s"),
            ("Last Sunset", "Exterior. The keeper watches sunset from the gallery deck. Wind in his hair. The automated sensor clicks on behind him — he doesn't flinch.", "Over Shoulder Wide", "10s"),
            ("Final Night — The Beam", "The lighthouse beam sweeps through fog. Each pass reveals a different memory: his wife, his children visiting, storms weathered. Dreamlike.", "Various", "45s"),
        ]
        
        for (i, data) in storyboardData.enumerated() {
            let card = StoryboardCard(title: data.0, sceneDescription: data.1, orderIndex: i, project: project)
            card.cameraAngle = data.2
            card.duration = data.3
            card.imageData = generatePlaceholderImage(
                index: i,
                title: data.0
            )
            context.insert(card)
        }
        
        // MARK: - Shot List
        let shots: [(String, String, ShotType, String, String, String, String, String, Bool)] = [
            ("1A", "Lighthouse at dawn — wide establishing", .establishing, "32mm Anamorphic", "Sc. 1", "Portland Head Light", "Ultra-wide of lighthouse against dawn sky. Beam still rotating. Tripod, locked off. Shoot at 5:45 AM.", "Need fog machine backup if no natural fog", true),
            ("1B", "Ocean waves — dawn light", .wideShot, "50mm Anamorphic", "Sc. 1", "Rocky shore below lighthouse", "Waves crashing on rocks, first golden light catching the spray. Slow motion 96fps.", "", true),
            ("2A", "Alarm clock close-up", .extremeCloseUp, "100mm Macro", "Sc. 2", "Keeper's quarters INT", "Vintage wind-up alarm clock. Hands reach in to silence it. Warm practical light from lantern.", "", true),
            ("2B", "Keeper sits up in bed", .mediumShot, "40mm Anamorphic", "Sc. 2", "Keeper's quarters INT", "Profile shot. Keeper swings legs out of bed. Window light mixing with lantern.", "", true),
            ("3A", "Polishing the lens — hands detail", .extremeCloseUp, "100mm Macro", "Sc. 3", "Lamp room INT", "Extreme close-up of weathered hands cleaning the Fresnel lens. Prismatic light refractions.", "Use practical lens reflections", false),
            ("3B", "Log book entry", .insert, "65mm Anamorphic", "Sc. 3", "Keeper's desk INT", "Insert of hand writing in log book. Decades of entries visible. Pen scratching sound important.", "", false),
            ("3C", "Coffee brewing — camp stove", .closeUp, "50mm Anamorphic", "Sc. 3", "Kitchen area INT", "Steam rising from kettle. Morning ritual. Natural window light.", "", false),
            ("4A", "Reading the letter — medium", .mediumShot, "40mm Anamorphic", "Sc. 4", "Keeper's desk INT", "Keeper reads automation notice. Camera slowly pushes in. No music — just wind and waves.", "Single take. Let the actor breathe.", false),
            ("4B", "Letter detail — insert", .insert, "100mm Macro", "Sc. 4", "Keeper's desk INT", "Cut to letter. Key phrases visible: 'automated system', 'no longer required', 'effective March 1.'", "", false),
            ("5A", "Spiral staircase — low angle tracking", .tracking, "24mm Anamorphic", "Sc. 5", "Lighthouse tower INT", "Follow keeper up 147 steps. Steadicam. His hand on the worn brass railing. Breathing audible.", "Steadicam op needs to rehearse — tight space", false),
            ("6A", "Lamp room — golden hour wide", .wideShot, "32mm Anamorphic", "Sc. 6", "Lamp room INT", "The hero shot. Keeper silhouetted against Fresnel lens. Golden hour light flooding through. Prismatic.", "MUST shoot between 6:15-6:45 PM", false),
            ("6B", "Fresnel lens detail — rack focus", .closeUp, "65mm Anamorphic", "Sc. 6", "Lamp room INT", "Rack focus from lens prisms to keeper's face reflected/refracted. Dreamlike quality.", "", false),
            ("7A", "Sunset from gallery deck", .wideShot, "40mm Anamorphic", "Sc. 7", "Gallery deck EXT", "Over-shoulder wide. Keeper watches his last sunset from the gallery. Wind in his jacket. Automated sensor clicks on behind him.", "Safety harness required — hidden under costume", true),
            ("7B", "Automated sensor activating", .insert, "100mm Macro", "Sc. 7", "Gallery deck EXT", "Close-up of the modern sensor unit clicking on. LED indicator. Sterile, mechanical. Contrast with the man.", "", false),
            ("8A", "Final beam through fog", .wideShot, "50mm Anamorphic", "Sc. 8", "Exterior various", "Lighthouse beam sweeping through fog. Multiple angles. Each sweep reveals/conceals. Ethereal.", "Fog machine x3 positioned downwind. Shoot all night coverage.", false),
        ]
        
        for (i, s) in shots.enumerated() {
            let shot = ShotListItem(
                shotNumber: s.0,
                title: s.1,
                shotType: s.2,
                lens: s.3,
                shotDescription: s.6,
                notes: s.7,
                orderIndex: i,
                scene: s.4,
                location: s.5,
                project: project
            )
            shot.isCompleted = s.8
            context.insert(shot)
        }
        
        // MARK: - Sample PDF document (create a minimal placeholder)
        let doc = ImportedDocument(
            name: "The Last Light — Script v4.pdf",
            documentType: .pdf,
            fileData: generateSamplePDF(),
            folderName: "General",
            project: project
        )
        context.insert(doc)
        
        let doc2 = ImportedDocument(
            name: "Location Scout — Portland Head.pdf",
            documentType: .pdf,
            fileData: generateSamplePDF(),
            folderName: "General",
            project: project
        )
        context.insert(doc2)
        
        // Folders
        let folder1 = ProjectFolder(name: "Scripts", project: project)
        let folder2 = ProjectFolder(name: "Location Scouts", project: project)
        let folder3 = ProjectFolder(name: "Reference Images", project: project)
        context.insert(folder1)
        context.insert(folder2)
        context.insert(folder3)
    }
    
    // MARK: - Placeholder Image Generator
    
    private static func generatePlaceholderImage(index: Int, title: String) -> Data? {
        let size = CGSize(width: 640, height: 360)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let colors: [(UIColor, UIColor)] = [
            (UIColor(red: 0.05, green: 0.10, blue: 0.20, alpha: 1), UIColor(red: 0.15, green: 0.25, blue: 0.40, alpha: 1)),   // Deep ocean blue
            (UIColor(red: 0.12, green: 0.08, blue: 0.05, alpha: 1), UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1)),   // Warm interior
            (UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1), UIColor(red: 0.20, green: 0.20, blue: 0.30, alpha: 1)),   // Night
            (UIColor(red: 0.10, green: 0.05, blue: 0.02, alpha: 1), UIColor(red: 0.45, green: 0.30, blue: 0.15, alpha: 1)),   // Golden hour
            (UIColor(red: 0.02, green: 0.08, blue: 0.15, alpha: 1), UIColor(red: 0.10, green: 0.30, blue: 0.45, alpha: 1)),   // Twilight
            (UIColor(red: 0.15, green: 0.12, blue: 0.08, alpha: 1), UIColor(red: 0.50, green: 0.35, blue: 0.18, alpha: 1)),   // Amber
            (UIColor(red: 0.20, green: 0.08, blue: 0.02, alpha: 1), UIColor(red: 0.60, green: 0.30, blue: 0.10, alpha: 1)),   // Sunset
            (UIColor(red: 0.03, green: 0.05, blue: 0.12, alpha: 1), UIColor(red: 0.08, green: 0.15, blue: 0.35, alpha: 1)),   // Fog night
        ]
        
        let colorPair = colors[index % colors.count]
        
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let context = ctx.cgContext
            
            // Gradient background
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: [colorPair.0.cgColor, colorPair.1.cgColor] as CFArray,
                locations: [0, 1]
            )!
            context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Subtle grid lines (storyboard frame marks)
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
            context.setLineWidth(0.5)
            // Rule of thirds
            for i in 1...2 {
                let x = size.width * CGFloat(i) / 3
                let y = size.height * CGFloat(i) / 3
                context.move(to: CGPoint(x: x, y: 0))
                context.addLine(to: CGPoint(x: x, y: size.height))
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.strokePath()
            
            // Center crosshair
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.1).cgColor)
            let cx = size.width / 2, cy = size.height / 2
            context.move(to: CGPoint(x: cx - 20, y: cy))
            context.addLine(to: CGPoint(x: cx + 20, y: cy))
            context.move(to: CGPoint(x: cx, y: cy - 20))
            context.addLine(to: CGPoint(x: cx, y: cy + 20))
            context.strokePath()
            
            // Frame number badge
            let badgeRect = CGRect(x: 16, y: 16, width: 40, height: 28)
            context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
            let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 6)
            context.addPath(badgePath.cgPath)
            context.fillPath()
            
            let frameNum = "\(index + 1)" as NSString
            let numAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let numSize = frameNum.size(withAttributes: numAttrs)
            frameNum.draw(at: CGPoint(x: badgeRect.midX - numSize.width / 2, y: badgeRect.midY - numSize.height / 2), withAttributes: numAttrs)
            
            // Title at bottom
            let titleBg = CGRect(x: 0, y: size.height - 50, width: size.width, height: 50)
            context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
            context.fill(titleBg)
            
            let titleStr = title as NSString
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            let titleSize = titleStr.size(withAttributes: titleAttrs)
            titleStr.draw(at: CGPoint(x: 16, y: size.height - 35), withAttributes: titleAttrs)
            
            // Aspect ratio markers (2.39:1 letterbox hint)
            context.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: 18))
            context.fill(CGRect(x: 0, y: size.height - 18, width: size.width, height: 18))
        }
        
        return image.jpegData(compressionQuality: 0.85)
    }
    
    // MARK: - Sample PDF Generator
    
    private static func generateSamplePDF() -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        return renderer.pdfData { context in
            context.beginPage()
            
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            
            ("THE LAST LIGHT" as NSString).draw(at: CGPoint(x: 72, y: 72), withAttributes: titleAttrs)
            
            let subtitle: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.gray
            ]
            ("A Short Film by [Director]" as NSString).draw(at: CGPoint(x: 72, y: 108), withAttributes: subtitle)
            ("Draft v4 — February 2026" as NSString).draw(at: CGPoint(x: 72, y: 130), withAttributes: subtitle)
            
            let body = """
            FADE IN:
            
            EXT. ROCKY COASTLINE — DAWN
            
            A lighthouse stands against a bruised sky. Its beam still sweeps through the pre-dawn darkness — a slow, mechanical pulse that has repeated without pause for over a century.
            
            The ocean heaves against granite. Spray catches the first light.
            
            TITLE CARD: "The Last Light"
            
            INT. KEEPER'S QUARTERS — CONTINUOUS
            
            A small room. Sparse. A single bed, military-neat. A wooden desk. Photographs pinned to the wall — faded, curling at the edges.
            
            A vintage wind-up alarm clock RINGS. A weathered hand reaches out and silences it.
            
            THOMAS HARGROVE (78) sits up. He's done this ten thousand times. His body knows the routine before his mind catches up.
            
            He strikes a match. Lights a lantern. The room fills with amber warmth.
            
                                    THOMAS (V.O.)
                        People ask me if I was lonely out here.
                        I tell them the sea is better company
                        than most people I've met.
            
            He pulls on a wool sweater. Steps into boots worn to the shape of his feet.
            
            INT. LAMP ROOM — MORNING
            
            Thomas climbs the final steps into the lamp room. The Fresnel lens — a masterwork of glass and brass — catches the morning light and fractures it into a thousand tiny rainbows.
            
            He begins his inspection. Running a cloth over the lens with practiced care. Every facet, every prism.
            
                                    THOMAS (V.O.)
                        The lens is a First Order Fresnel.
                        Hand-ground in Paris, 1867. Eight
                        hundred pounds of glass and brass.
                        They don't make them anymore.
                        They don't make men to tend them either.
            """
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let bodyFormatted: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Courier", size: 12) ?? UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            (body as NSString).draw(in: CGRect(x: 72, y: 170, width: 468, height: 580), withAttributes: bodyFormatted)
        }
    }
}
