import SwiftUI
import PencilKit

struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasData: Data?
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .white, width: 3)
        canvas.backgroundColor = UIColor.secondarySystemBackground
        canvas.delegate = context.coordinator
        
        if let data = canvasData, let drawing = try? PKDrawing(data: data) {
            canvas.drawing = drawing
        }
        
        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        context.coordinator.toolPicker = toolPicker
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasData: $canvasData)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var canvasData: Data?
        var toolPicker: PKToolPicker?
        
        init(canvasData: Binding<Data?>) {
            _canvasData = canvasData
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            canvasData = canvasView.drawing.dataRepresentation()
        }
    }
}
