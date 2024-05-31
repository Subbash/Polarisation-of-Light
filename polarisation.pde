import controlP5.*;

ControlP5 cp5;
PGraphics plotWindow;
int numPoints = 150; // Number of points to plot the wave
float waveLength = 100; // Wavelength
float waveFrequency = 0.02; // Frequency of the wave
float phaseShift = PI / 2; // Phase shift between E and B fields
float angle = 0; // Initial angle for animation
float camAngleX = 0; // Camera angle in the X direction
float camAngleY = 0; // Camera angle in the Y direction
float camRadius = 500; // Camera distance from the origin
float arrowSize = 2; // Size of the arrowhead
int electricTransparency = 255; // Transparency for electric field
int magneticTransparency = 255; // Transparency for magnetic field
int resultantTransparency = 255;
float zoomFactor = 1; // Zoom factor
int plotWindowWidth = 800; // Width of the plot window
int plotWindowHeight = 800; // Height of the plot window

void setup() {
  size(1800, 1000, P3D);
  plotWindow = createGraphics(plotWindowWidth, plotWindowHeight, P3D);

  cp5 = new ControlP5(this);
  
  cp5.addSlider("electricTransparency")
     .setSize(120, 20)
     .setPosition(900, 200)
     .setRange(1, 255)
     .setValue(255)
     .setNumberOfTickMarks(24) // Add tick marks
     .setLabel("Electric Transparency"); // Name for the slider
     
  cp5.addSlider("magneticTransparency")
     .setPosition(900, 400)
     .setSize(120, 20)
     .setRange(1, 255)
     .setValue(255)
     .setNumberOfTickMarks(24) // Add tick marks
     .setLabel("Magnetic Transparency"); // Name for the slider
     
  cp5.addSlider("resultantTransparency")
     .setPosition(900, 600)
     .setSize(120, 20)
     .setRange(1, 255)
     .setValue(255)
     .setNumberOfTickMarks(24) // Add tick marks
     .setLabel("Resultant Transparency"); // Name for the slider
  
  // Add slider for controlling phase of the second wave
  cp5.addSlider("phaseShift")
     .setPosition(900, 800)
     .setSize(120, 20)
     .setRange(-PI, PI) // Range from 0 to 2*pi
     .setValue(0) // Initial value
     .setNumberOfTickMarks(255) // Add tick marks
     .setLabel("Phase Shift"); // Name for the slider
}

void draw() {
  background(255);
  plotWindow.beginDraw();
  plotWindow.background(255);
  plotWindow.lights();
  plotWindow.strokeWeight(2);
  
  // Camera position based on mouse movement and zoom factor
  float camX = camRadius * cos(camAngleY) * sin(camAngleX) / zoomFactor;
  float camY = camRadius * sin(camAngleY) / zoomFactor;
  float camZ = camRadius * cos(camAngleY) * cos(camAngleX) / zoomFactor;
  
  // Set the camera position
  plotWindow.camera(camX, camY, camZ, 0, 0, 0, 0, 1, 0);
  
  drawAxes();
  drawWave();
  
  plotWindow.endDraw();
  image(plotWindow, 50, 50);
  
  angle += waveFrequency;
  
  // Calculate the distance between camera and origin
  float distance = dist(0, 0, 0, camX, camY, camZ);
  // Adjust zoom factor based on distance
  zoomFactor = camRadius / distance;
}

void drawAxes() {
  plotWindow.strokeWeight(1);
  
  // Z-axis (Direction of propagation)
  plotWindow.stroke(0);
  plotWindow.line(0, 0, -200, 0, 0, 200);
  
  // X-axis
  plotWindow.stroke(255, 0, 0);
  plotWindow.line(-200, 0, 0, 200, 0, 0);
  
  // Y-axis
  plotWindow.stroke(0, 0, 255);
  plotWindow.line(0, -200, 0, 0, 200, 0);
  
  // Labels
  plotWindow.textSize(12);
  plotWindow.fill(0);
  plotWindow.text("z", 0, 0, 210); // Label for Z-axis
  plotWindow.text("x", 210, 0, 0); // Label for X-axis
  plotWindow.text("y", 0, 210, 0); // Label for Y-axis
}

void drawWave() {
  plotWindow.strokeWeight(2);
  
  // Electric field (Red) - along Y-axis
  plotWindow.stroke(255, 0, 0, electricTransparency);
  for (int i = 0; i < numPoints; i++) {
    float z = map(i, 0, numPoints, -200, 200);
    float y = 50 * sin(TWO_PI * (z / waveLength) + angle);
    drawArrow(0, 0, z, 0, y, z, arrowSize,color(255, 0, 0, electricTransparency));
  }
  
  // Magnetic field (Blue) - along X-axis
  plotWindow.stroke(0, 0, 255, magneticTransparency);
  for (int i = 0; i < numPoints; i++) {
    float z = map(i, 0, numPoints, -200, 200);
    float x = 50 * sin(TWO_PI * (z / waveLength) + angle + phaseShift);
    drawArrow(0, 0, z, x, 0, z, arrowSize,color(0, 0, 255,magneticTransparency));
  }
  
  // Resultant wave (Magenta) - sum of electric and magnetic fields
  plotWindow.stroke(0, 0, 0, resultantTransparency);
  for (int i = 0; i < numPoints; i++) {
    float z = map(i, 0, numPoints, -200, 200);
    float y = 50 * sin(TWO_PI * (z / waveLength) + angle);
    float x = 50 * sin(TWO_PI * (z / waveLength) + angle + phaseShift);
    drawArrow(0, 0, z, x, y, z, arrowSize,color(0, 0, 0,resultantTransparency ));
  }
}

void drawArrow(float x1, float y1, float z1, float x2, float y2, float z2, float size, color arrowColor) {
  // Draw the main line of the arrow
  plotWindow.line(x1, y1, z1, x2, y2, z2);
  plotWindow.stroke(arrowColor);
  
  // Calculate the direction of the arrow
  float dx = x2 - x1;
  float dy = y2 - y1;
  float dz = z2 - z1;
  
  // Normalize the direction
  float len = dist(x1, y1, z1, x2, y2, z2);
  dx /= len;
  dy /= len;
  dz /= len;
  
  // Calculate points for the arrowhead
  float arrowX = x2 - dx * size;
  float arrowY = y2 - dy * size;
  float arrowZ = z2 - dz * size;
  
  plotWindow.fill(arrowColor);
  
  plotWindow.beginShape(TRIANGLES);
  plotWindow.vertex(x2, y2, z2);
  plotWindow.vertex(arrowX + dy * size * 0.5, arrowY - dx * size * 0.5, arrowZ);
  plotWindow.vertex(arrowX - dy * size * 0.5, arrowY + dx * size * 0.5, arrowZ);
  plotWindow.endShape();
}

void mouseDragged() {
  if (mouseX >= 50 && mouseX <= 50 + plotWindowWidth && mouseY >= 50 && mouseY <= 50 + plotWindowHeight) {
    camAngleX -= (mouseX - pmouseX) * 0.01;
    camAngleY -= (mouseY - pmouseY) * 0.01;
    camAngleY = constrain(camAngleY, -PI/2, PI/2); // Limit vertical rotation
  }
}

void mouseWheel(MouseEvent event) {
  if (mouseX >= 50 && mouseX <= 50 + plotWindowWidth && mouseY >= 50 && mouseY <= 50 + plotWindowHeight) {
    float e = event.getCount();
    zoomFactor *= 1.0 + e * 0.05; // Adjust zoom factor based on wheel movement
  }
}
