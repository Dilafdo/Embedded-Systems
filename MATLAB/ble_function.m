% Connect to ESP32 via Bluetooth SPP
deviceName = 'ESP32_MPU';  % Replace with your ESP32 Bluetooth device name
bt = bluetooth(deviceName, 1);  % Channel 1

% Thin rectangular box dimensions
lengthX = 1.0;
widthY  = 0.6;
heightZ = 0.1;

% Vertices of the box centered at origin

x = [0.5 -0.5]*lengthX;   % ← flipped X
y = [-0.5 0.5]*widthY;    % ← flipped Y
z = [-0.5 0.5]*heightZ;
[X, Y, Z] = meshgrid(x, y, z);
boxVerts = [X(:), Y(:), Z(:)];

[X, Y, Z] = meshgrid(x, y, z);
boxVerts = [X(:), Y(:), Z(:)];

% Box faces
faces = [
    1 2 4 3;  % Bottom
    5 6 8 7;  % Top
    1 2 6 5;
    2 4 8 6;
    4 3 7 8;
    3 1 5 7
];

% Setup figure
figure('Name', '3D MPU Orientation Box with Markers');
ax = axes('XLim', [-1.5 1.5], 'YLim', [-1.5 1.5], 'ZLim', [-1.5 1.5]);
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3); grid on; axis equal; hold on;

% Draw the box
patchObj = patch('Vertices', boxVerts, ...
                 'Faces', faces, ...
                 'FaceColor', [0.2 0.8 0.9], ...
                 'FaceAlpha', 0.9);

% Top marker: red triangle on top face
topMarkerLocal = [0 0 heightZ/2; 
                  0.05 0 heightZ/2; 
                  0 0.05 heightZ/2];

topMarker = patch('Vertices', topMarkerLocal, ...
                  'Faces', [1 2 3], ...
                  'FaceColor', 'red');

% Front marker: small forward-facing blue arrow
frontArrowLocal = [0 0 0; 
                   0.2 0 0];  % Along +X

frontArrow = quiver3(0, 0, 0, 0.2, 0, 0, ...
                    'Color', 'blue', ...
                    'LineWidth', 2, ...
                    'MaxHeadSize', 2);

% Reference axes
quiver3(0,0,0,1,0,0,'r','LineWidth',1.5); % X
quiver3(0,0,0,0,1,0,'g','LineWidth',1.5); % Y
quiver3(0,0,0,0,0,1,'b','LineWidth',1.5); % Z

disp("Streaming orientation from ESP32...");

while true
    try
        if bt.NumBytesAvailable > 0
            rawLine = readline(bt);
            angles = sscanf(rawLine, '%f,%f,%f');

            if numel(angles) == 3
                yaw   = deg2rad(angles(1));
                pitch = -deg2rad(angles(2));
                roll  = deg2rad(angles(3));

                % Rotation matrices
                Rx = [1 0 0;
                      0 cos(roll) -sin(roll);
                      0 sin(roll) cos(roll)];
                Ry = [cos(pitch) 0 sin(pitch);
                      0 1 0;
                     -sin(pitch) 0 cos(pitch)];
                Rz = [cos(yaw) -sin(yaw) 0;
                      sin(yaw) cos(yaw) 0;
                      0 0 1];
                R = Rz * Ry * Rx;

                % Rotate and update box
                newBoxVerts = (R * boxVerts')';
                set(patchObj, 'Vertices', newBoxVerts);

                % Rotate and update top marker
                newTopVerts = (R * topMarkerLocal')';
                set(topMarker, 'Vertices', newTopVerts);

                % Update front arrow
                origin = (R * [0 0 0]')';
                tip = (R * [0.2 0 0]')';
                dir = tip - origin;
                set(frontArrow, 'XData', origin(1), ...
                                'YData', origin(2), ...
                                'ZData', origin(3), ...
                                'UData', dir(1), ...
                                'VData', dir(2), ...
                                'WData', dir(3));
                drawnow limitrate;
            end
        end
    catch ME
        disp("Error:");
        disp(ME.message);
        break;
    end
end
