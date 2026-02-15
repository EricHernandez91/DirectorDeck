import Foundation
import SwiftData
import UIKit

struct SampleDataService {
    
    static func loadIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Project>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        
        createTheLastLight(context: context)
        createBostonShoot(context: context)
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
    
    // MARK: - Boston Shoot
    
    static func importCFAProject(context: ModelContext) {
        createBostonShoot(context: context)
    }
    
    static func loadAllSampleProjects(context: ModelContext) {
        createTheLastLight(context: context)
        createBostonShoot(context: context)
    }
    
    private static func createBostonShoot(context: ModelContext) {
        // MARK: - Project
        let project = Project(
            name: "Matt & Harrison's Story",
            projectDescription: "CFA The Approach 2026. Copley Square, Boston. Interviews + leadership meeting reenactment + restaurant B-roll. DJI Ronin 4D (A-cam) + Sony FX6 (B-cam/handheld).",
            colorHex: "#C41230"
        )
        context.insert(project)
        
        // MARK: - Creative Brief
        let brief = CreativeBrief(
            title: "Creative Brief — CFA The Approach 2026",
            content: """
            CFA THE APPROACH 2026 — Matt & Harrison Story
            ==============================================
            
            LOCATION: Copley Square, Chick-fil-A interior, Boston
            
            CAMERAS:
            • A-Cam: DJI Ronin 4D (locked/stabilized, 23.98 & 48fps)
            • B-Cam: Sony FX6 (handheld, 23.98fps)
            
            SECTIONS:
            1. Harrison Interview (2-cam setup)
            2. Matt Interview (2-cam setup)
            3. Matt & Harrison Joint Interview
            4. Leadership Meeting (pre-meeting details + in-progress)
            5. Restaurant B-Roll: The Rush (FX6 handheld, NO faces, frenetic energy)
            6. Restaurant B-Roll: The System (Ronin 4D stabilized, faces visible, smooth)
            7. Boston City Energy (FX6 handheld exteriors)
            8. Transition Shots (receipt pull, easel pad reveal, plexiglass closing)
            
            GENERAL NOTES:
            • Rush shots: handheld, medium/tight only, NO faces. Fast cuts, frantic energy.
            • System shots: stabilized on the 4D, medium/wide, faces visible. Smooth, organized, efficient.
            • If talent turnout is low for leadership meeting, shoot tighter than planned.
            • Plexiglass rig needed for T2 and shot 4D — shoot early while board is full or pre-dress it.
            """,
            project: project
        )
        context.insert(brief)
        
        // MARK: - Interview Subjects & Questions
        
        // Harrison — Talent Director
        let harrison = InterviewSubject(
            name: "Harrison",
            role: "Talent Director",
            notes: "Focus on EVP and high-level outcomes. Polished communicator — guide toward authentic, not rehearsed.",
            project: project
        )
        context.insert(harrison)
        
        let harrisonQs: [(String, String)] = [
            ("Tell us about yourself and your role at the restaurant.", ""),
            ("What does it mean to you to be a Talent Director? How do you see your role in the bigger picture?", ""),
            ("When you first started working with Matt on a talent strategy, what was the biggest people challenge you were facing?", ""),
            ("What were your employees saying about your restaurant before EVP?", ""),
            ("How would you describe the culture at your restaurant today compared to before you had a deliberate talent strategy?", ""),
            ("Take me to the moment in time when you were invited into the leadership meeting. What was it like? What was the general feeling?", ""),
            ("What did you walk away with that day from the meeting?", ""),
            ("What does your employee value proposition look like? Be tactical. Why do people choose to work here and stay?", ""),
            ("How did you put the EVP into action?", ""),
            ("When you think about your Employee Value Proposition, what did you want Team Members to genuinely feel was different here?", ""),
            ("How has having a long-term talent strategy changed the way you recruit and retain team members?", ""),
            ("What does it look like when a team member grows into a leader at your restaurant?", ""),
            ("Can you share a specific moment where you saw the strategy paying off? A person or a result that made it real?", ""),
            ("How do you and Matt partner together on talent decisions? What does that dynamic look like?", ""),
            ("What would you say to another Talent Director who feels like they are just filling shifts instead of building something bigger?", ""),
            ("How do you keep your talent strategy aligned with the business as it grows and changes?", ""),
            ("What do you hope every employee gains from working at your CFA?", ""),
        ]
        for (i, q) in harrisonQs.enumerated() {
            let question = InterviewQuestion(text: q.0, notes: q.1, orderIndex: i, subject: harrison)
            context.insert(question)
        }
        
        // Matt — Operator
        let matt = InterviewSubject(
            name: "Matt",
            role: "Operator",
            notes: "Matt is the emotional heart. Go for emotion. Vision, scaling, people and purpose.",
            project: project
        )
        context.insert(matt)
        
        let mattQs: [(String, String)] = [
            ("Tell us about your journey. How did you get to where you are today?", ""),
            ("Before you implemented this talent strategy, what was broken? Give us the real details. What did a bad day look like, what were you losing, and what was it costing you?", ""),
            ("If the dining room walls could have talked back then, what would they have said about the team or the pressure they were under?", ""),
            ("When did you realize you needed a deliberate, long-term talent strategy?", ""),
            ("What kind of environment were you intentionally trying to create for your team? What did you hope your team would feel and say about working here?", ""),
            ("What was the turning point? What was the moment in time where things shifted? What did you do and how did you respond?", ""),
            ("What questions were you asking yourself during this moment of shift, to help lead your restaurant down the path it needed to go?", ""),
            ("How do you think about the relationship between your business strategy and your talent strategy?", ""),
            ("What role does Harrison play in executing your vision for talent?", ""),
            ("How did aligning the EVP with your business strategy change the kinds of leaders you started to see emerge?", ""),
            ("What does future-proofing your business through talent mean to you in practical terms?", ""),
            ("How has investing in your people impacted your business results?", ""),
            ("Can you tell us about a team member whose growth story embodies what you are building?", ""),
            ("What is the hardest part about leading with a people-first approach when the labor market is tough?", ""),
            ("What is the one thing you are most proud of that has come from this work?", ""),
            ("You are scaling across multiple markets. How do you grow without losing the culture that makes your restaurant special?", ""),
        ]
        for (i, q) in mattQs.enumerated() {
            let question = InterviewQuestion(text: q.0, notes: q.1, orderIndex: i, subject: matt)
            context.insert(question)
        }
        
        // Matt & Harrison — Joint Interview
        let joint = InterviewSubject(
            name: "Matt & Harrison",
            role: "Joint Interview",
            notes: "Quick, conversational. Natural interactions and reaction shots.",
            project: project
        )
        context.insert(joint)
        
        let jointQs: [(String, String)] = [
            ("What are the tangible signs today that this strategy is working — for the business and the people?", ""),
            ("What keeps you anchored in purpose as you scale?", ""),
            ("Where do you see your restaurant, and your people, in five years?", ""),
            ("How would you each describe your working relationship in one sentence?", ""),
            ("What is one thing you have learned from each other?", ""),
            ("What is a win you have celebrated together recently?", ""),
            ("If those same walls could talk today, what would they say about working here?", ""),
            ("Finish this sentence: The future of our restaurant depends on ___.", ""),
        ]
        for (i, q) in jointQs.enumerated() {
            let question = InterviewQuestion(text: q.0, notes: q.1, orderIndex: i, subject: joint)
            context.insert(question)
        }
        
        // MARK: - Storyboard Cards
        let storyboardData: [(String, String, String, String)] = [
            ("Harrison Interview — Wide", "Harrison seated interview, standard 2-cam setup. A-cam wide/medium.", "DJI Ronin 4D, locked, eye-level", ""),
            ("Matt Interview — Wide", "Matt seated interview, standard 2-cam setup. A-cam wide/medium.", "DJI Ronin 4D, locked, eye-level", ""),
            ("Joint Interview — Medium-Wide", "Matt and Harrison side by side, wider frame for both. Conversational setup.", "DJI Ronin 4D, locked or slow push", ""),
            ("Pre-Meeting Details", "Empty sticky notes, untouched pads, pens ready. Anticipation before the meeting.", "Static, eye-level", ""),
            ("Leadership Meeting — Wide", "Group seated around table, meeting in progress. Collaborative energy.", "Static or slow push, eye-level", ""),
            ("The Rush — Counter Action", "Front counter action. Hands on register, food handoff, bagging. No faces, just motion.", "FX6, handheld, fast", ""),
            ("The Rush — Kitchen", "Kitchen hustle. Prep, cooking, plating. Tight on hands and product. Frenetic energy.", "FX6, handheld", ""),
            ("The System — Team Serving", "Team serving guests with purpose. Smiling, eye contact. Faces visible. The system is working.", "Ronin 4D, stabilized, slow push", ""),
            ("The System — Hero Customer Shot", "OTS customer ordering. Employee smiling, kitchen visible behind. The hero customer service shot.", "Ronin 4D, stabilized, slow dolly", ""),
            ("Boston City Energy", "Bikes, cars, pedestrians, city texture. Urban energy, quick cuts.", "FX6, handheld, fast", ""),
            ("Transition — Receipt Pull", "CU receipt printer. Receipt prints, hand pulls toward camera. Paper fills frame. Match cut.", "FX6, static/slight push", ""),
            ("Transition — Easel Pad Reveal", "Looking at easel pad. Employee peels page up. Camera pulls back revealing meeting context.", "FX6, static then pull back", ""),
            ("Closing — Plexiglass Blackout", "Camera behind plexiglass. Team sticks notes. Final note covers lens. Blackout. CLOSING SHOT.", "Ronin 4D, dana dolly push", ""),
        ]
        
        for (i, data) in storyboardData.enumerated() {
            let card = StoryboardCard(title: data.0, sceneDescription: data.1, orderIndex: i, project: project)
            card.cameraAngle = data.2
            card.duration = data.3
            card.imageData = generatePlaceholderImage(index: i, title: data.0)
            context.insert(card)
        }
        
        // MARK: - Shot List (exact from PDF)
        let shots: [(String, String, ShotType, String, String, String, String, String)] = [
            // Harrison Interview
            ("1", "Harrison seated interview — A-cam wide/medium", .wideShot, "DJI Ronin 4D", "Harrison Interview", "Copley Square CFA INT",
             "Harrison seated interview, standard 2-cam setup. A-cam on the wide/medium. 23.98fps, locked, eye-level.", ""),
            ("1A", "Harrison interview B-cam — tight/detail", .closeUp, "Sony FX6", "Harrison Interview", "Copley Square CFA INT",
             "Harrison interview B-cam. Tight/detail shot. 23.98fps, handheld, eye-level.", ""),
            // Matt Interview
            ("2", "Matt seated interview — A-cam wide/medium", .wideShot, "DJI Ronin 4D", "Matt Interview", "Copley Square CFA INT",
             "Matt seated interview, standard 2-cam setup. A-cam on the wide/medium. 23.98fps, locked, eye-level.", ""),
            ("2A", "Matt interview B-cam — tight/detail", .closeUp, "Sony FX6", "Matt Interview", "Copley Square CFA INT",
             "Matt interview B-cam. Tight/detail shot. 23.98fps, handheld, eye-level.", ""),
            // Matt & Harrison Joint Interview
            ("3", "Joint interview — medium-wide both in frame", .wideShot, "DJI Ronin 4D", "Joint Interview", "Copley Square CFA INT",
             "Matt and Harrison side by side, wider frame for both. Conversational setup. 23.98fps, locked or slow push, eye-level.", ""),
            ("3A", "Joint interview — singles and reactions", .closeUp, "Sony FX6", "Joint Interview", "Copley Square CFA INT",
             "Singles and reaction shots during joint interview. 23.98fps, handheld, eye-level.", ""),
            ("3B", "Candid — walking the floor, talking to team", .handheld, "Sony FX6", "Joint Interview", "Copley Square CFA INT/EXT",
             "Matt or Harrison walking the floor, talking to team. Candid, not interview. 23.98fps, handheld documentary, eye-level.", ""),
            ("3C", "Harrison hero portrait", .mediumShot, "DJI Ronin 4D", "Joint Interview", "Copley Square CFA INT",
             "Harrison hero portrait. Starts wider, slow push in. Smiling into frame. 48fps, slow push, eye-level.", ""),
            ("3D", "Matt hero portrait", .mediumShot, "DJI Ronin 4D", "Joint Interview", "Copley Square CFA INT",
             "Matt hero portrait. Starts wider, slow push in. Smiling into frame. 48fps, slow push, eye-level.", ""),
            ("3E", "Matt and Harrison together — hero portrait", .twoShot, "DJI Ronin 4D", "Joint Interview", "Copley Square CFA INT",
             "Matt and Harrison together, hero portrait. Starts wider, slow push in. Both smiling into frame. 48fps, slow push, eye-level.", ""),
            // Leadership Meeting — Pre-Meeting Details
            ("4", "Empty sticky notes on table — anticipation", .closeUp, "", "Leadership Meeting", "Copley Square CFA INT",
             "Empty sticky notes on the table, untouched. Anticipation before the meeting. Same plexiglass rig as T2. Shoot early while board is full or pre-dress it. 23.98fps, static, eye-level.", ""),
            ("4A", "Medium of sticky notes spread on table", .mediumShot, "", "Leadership Meeting", "Copley Square CFA INT",
             "Medium of sticky notes spread across the table, ready to be used. 23.98fps, static, eye-level.", ""),
            ("4B", "Empty notepads on wall — clean slate", .wideShot, "", "Leadership Meeting", "Copley Square CFA INT",
             "Empty notepads hanging on the wall. Clean slate before the session begins. 23.98fps, static, eye-level.", ""),
            ("4C", "Pens and pencils next to sticky notes", .closeUp, "", "Leadership Meeting", "Copley Square CFA INT",
             "Pens and pencils next to sticky notes, waiting to be used. 23.98fps, static, eye-level/tabletop.", ""),
            ("4D", "Behind plexiglass — looking through sticky notes", .dolly, "DJI Ronin 4D", "Leadership Meeting", "Copley Square CFA INT",
             "Behind the plexiglass, looking through a wall of sticky notes already placed on the glass. Dana dolly gently pushes in. We see the meeting room through the notes, as if looking through the strategy itself. Same plexiglass rig as T2. Shoot early while board is full or pre-dress it. 23.98fps, dana dolly gentle push in, eye-level.", ""),
            // Leadership Meeting — In Progress
            ("5", "Wide establishing — group meeting in progress", .establishing, "", "Leadership Meeting", "Copley Square CFA INT",
             "Wide establishing shot. Group seated around table, meeting in progress. Collaborative energy, natural feel. If talent turnout is low, change wide to medium and shoot tighter than planned. 23.98fps, static or slow push, eye-level.", ""),
            ("5A", "2-3 people mid-discussion with sticky notes", .mediumShot, "", "Leadership Meeting", "Copley Square CFA INT",
             "2-3 people mid-discussion, gesturing at sticky notes on the board. 23.98fps, handheld, eye-level.", ""),
            ("5B", "Insert — hands writing sticky notes, placing on board", .insert, "", "Leadership Meeting", "Copley Square CFA INT",
             "Insert of hands writing on sticky notes, placing them on board/pad. 23.98fps, handheld, eye-level.", ""),
            ("5C", "Tight faces — reactions: listening, nodding, laughing", .closeUp, "", "Leadership Meeting", "Copley Square CFA INT",
             "Tight on individual faces. Reactions: listening, nodding, laughing. 23.98fps, handheld, eye-level, shallow DOF.", ""),
            ("5D", "OTS leader addressing the group", .overTheShoulder, "", "Leadership Meeting", "Copley Square CFA INT",
             "Over-the-shoulder of leader addressing the group. Leadership in action. 23.98fps, handheld, OTS.", ""),
            // The Rush (FX6 Handheld — NO faces)
            ("6", "Front counter action — register, handoff, bagging", .handheld, "Sony FX6", "The Rush", "Copley Square CFA INT",
             "Front counter action. Hands on register, food handoff, bagging orders. No faces, just motion and speed. 23.98fps, handheld fast, eye-level.", "ALL RUSH SHOTS: handheld, medium/tight only, NO faces. Fast cuts, frantic energy."),
            ("6A", "Kitchen hustle — prep, cooking, plating", .handheld, "Sony FX6", "The Rush", "Copley Square CFA INT",
             "Kitchen hustle. Prep, cooking, plating. Tight on hands and product. Frenetic energy, the rush is real. Order screens beeping, in the red. 23.98fps, handheld, eye-level.", ""),
            ("6B", "Insert details — wrapping, sauce, timers, ticket printers", .insert, "Sony FX6", "The Rush", "Copley Square CFA INT",
             "Insert details. Hands wrapping sandwiches, sauce bottles, timers, ticket printers firing. Texture of the chaos. 23.98fps, handheld, eye-level/high angle.", ""),
            ("6C", "Station movement — bodies between stations, whip pans", .handheld, "Sony FX6", "The Rush", "Copley Square CFA INT",
             "Team members moving between stations. Quick cuts, bodies in motion, no faces. Feels like controlled chaos. 23.98fps, handheld with whip pans, eye-level.", ""),
            ("6D", "Order staging and bagging — assembly line output", .handheld, "Sony FX6", "The Rush", "Copley Square CFA INT",
             "Order staging and bagging. Hands assembling orders, stacking trays, bags sliding down the line. The output of the machine. 23.98fps, handheld, eye-level/low angle.", ""),
            // The System (Ronin 4D Stabilized — faces visible)
            ("7", "Team serving guests with purpose — faces visible", .steadicam, "DJI Ronin 4D", "The System", "Copley Square CFA INT",
             "Team serving guests with purpose. Smiling, eye contact, smooth. Faces visible now. The system is working. 23.98fps, stabilized slow push, eye-level.", "ALL SYSTEM SHOTS: stabilized on the 4D, medium/wide, faces visible. Smooth, organized, efficient."),
            ("7A", "OTS customer ordering — hero customer service shot", .overTheShoulder, "DJI Ronin 4D", "The System", "Copley Square CFA INT",
             "Over the shoulder of a customer ordering at the register. Employee taking the order with a big smile, kitchen action visible behind them. The hero customer service shot. 23.98fps, stabilized slow dolly, eye-level/OTS.", ""),
            ("7B", "Culture moments — huddle, high-five, training", .steadicam, "DJI Ronin 4D", "The System", "Copley Square CFA INT",
             "Huddle, high-five, training moment. Culture in action. Faces, smiles, connection. This is why talent matters. 23.98fps, stabilized follows action, eye-level.", ""),
            ("7C", "Polished details — name tags, uniforms, hands at work", .closeUp, "DJI Ronin 4D", "The System", "Copley Square CFA INT",
             "Name tags, uniforms, hands at work. Polished detail shots. Everything in its place. 48fps, stabilized, eye-level/tabletop.", ""),
            ("7D", "Copley Square exterior — signage, city life", .establishing, "DJI Ronin 4D", "The System", "Copley Square EXT",
             "Copley Square exterior. Restaurant signage, city life around it. Establishing shot, the world outside the system. 23.98fps, stabilized slow pan, eye-level/low angle.", ""),
            // Boston City Energy
            ("8", "Bike whizzing past camera", .handheld, "Sony FX6", "Boston City Energy", "Copley Square EXT",
             "Bike whizzing past camera. Tight, fast, blur of motion. Urban energy. 23.98fps, handheld fast, eye-level/low angle.", ""),
            ("8A", "Cars through intersection — wheels, bumpers, reflections", .handheld, "Sony FX6", "Boston City Energy", "Copley Square EXT",
             "Cars moving through intersection. Tight on wheels, bumpers, reflections. City in motion. 23.98fps, handheld, eye-level/low angle.", ""),
            ("8B", "Pedestrians — sidewalks, crosswalks, people with purpose", .handheld, "Sony FX6", "Boston City Energy", "Copley Square EXT",
             "Pedestrians on sidewalks, crosswalks, people with purpose. Quick cuts, tight framing, Boston moving fast. 23.98fps, handheld with whip pans, eye-level.", ""),
            ("8C", "City texture — street signs, cobblestone, T station, coffee cups", .closeUp, "Sony FX6", "Boston City Energy", "Copley Square EXT",
             "City texture. Street signs, cobblestone, T station entrance, coffee cups, shoe steps. The rhythm of Boston. 48fps, handheld, eye-level/low angle.", ""),
            // Transition Shots
            ("T1", "Receipt printer — receipt pull toward camera", .closeUp, "Sony FX6", "Transitions", "Copley Square CFA INT",
             "Close-up on receipt printer. Receipt prints out. Employee reaches in and pulls the receipt toward camera. The paper fills the frame as it comes toward lens. 23.98fps, static/slight push, eye-level. TRANSITION OUT: paper fills frame. Match cut to T1B.", ""),
            ("T1B", "Easel pad peel — pull back reveals meeting", .wideShot, "Sony FX6", "Transitions", "Copley Square CFA INT",
             "Looking straight at a 3M Post-it Easel Pad. Employee peels the page up toward camera. As the bottom edge meets the lens, we match from T1. Camera pulls back to reveal the employee writing on the pad in a leadership meeting. 23.98fps, static then pull back, eye-level. TRANSITION IN: paper peels up to match T1 receipt pull.", ""),
            ("T2", "Plexiglass sticky note push — CLOSING SHOT", .dolly, "DJI Ronin 4D", "Transitions", "Copley Square CFA INT",
             "Camera behind plexiglass mounted in a black box (no reflections). Dana dolly pushes toward the glass as team members stick sticky notes to it. Camera keeps pushing in until it lands on an empty square where someone places a final sticky note, covering the lens. Blackout. This is the last shot of the edit. 23.98fps, dana dolly push toward plexiglass, eye-level. BUILD: plexiglass sheet + black box rig to kill reflections. CLOSING SHOT of the piece. Sticky note blackout is the final frame.", ""),
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
            context.insert(shot)
        }
        
        // MARK: - Folders
        let folder1 = ProjectFolder(name: "Scripts", project: project)
        let folder2 = ProjectFolder(name: "B-Roll Selects", project: project)
        let folder3 = ProjectFolder(name: "Interview Transcripts", project: project)
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
