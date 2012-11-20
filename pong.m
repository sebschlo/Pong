function pong()
% Game of Pong!

%Game Parameters and initializations
dt = .001; %time step
gameMode = 0; %single player or two player
round = 0; %whether round is active or not
loop = 0; %counts the number of loops to release the upgrades
upgradeActive = 0; %determines what upgrade is active
controlL=0; %keyboard input
controlR=0; %keyboard input

%Load Sounds
bup = wavread('pong.wav');
upg = wavread('coin.wav');

%User Interface
while gameMode ~= 1 && gameMode ~= 2
    gameMode = input('Please enter 1 for Single Player mode or 2 for Two Player mode...  ');
    if gameMode ~= 1 && gameMode ~= 2
        disp('You fool!');
    end
end

%Set up figure
f = figure;
set (f,'Color','k','toolbar','none','menubar','none');
title('PONG','FontSize',25,'Color','w');
line([6 6],[0 10],'LineStyle',':','LineWidth',1,'Color','w');
line([0 0 0 0 12 12 0 12],[0 10 12 0 0 10 10 10],'LineStyle','-','LineWidth',2,'Color','w');
axis([0 12 0 10]);
axis off

%Random direction for initial ball throw
if randi(2) == 1
    ballState = [6,5,35,randi([-20 20])];
elseif randi(2) == 2
    ballState = [6,5,-35,randi([-20 20])];
end
upgradeState = [6 5 0 0];

%Initialize plot with ball position
hold on
h = plot (ballState(1), ballState(2), 'w.', 'MarkerSize', 5);
u = plot (upgradeState(1), 5, 'w+', 'MarkerSize',5);

%Initialize plot with paddles
leftSize = 1;
leftPos = 4.5;
rightSize = 1;
rightPos = 4.5;
leftPaddle = line([1 1],[leftPos leftPos+leftSize],'LineWidth',5,'Color','w');
rightPaddle = line([11 11],[rightPos rightPos+rightSize],'LineWidth',5,'Color','w');

%Initialize plot with score and other data
scoreL = 0;
scoreR = 0;
leftText = text(2,8,num2str(scoreL),'FontSize',45,'Color','w','FontName','Courier');
rightText = text(9.5,8,num2str(scoreR),'FontSize',45,'Color','w','FontName','Courier');
textUpgrade = text(5,-.5,' ','FontSize',8,'Color','w','FontName','Courier');
if gameMode == 1
    text(8.7,-.5,'Control with P and L','FontSize',8,'Color','w','FontName','Courier');
elseif gameMode == 2
    text(8.7,-.5,'Control with P and L','FontSize',8,'Color','w','FontName','Courier');
    text(0,-.5,'Control with Q and A','FontSize',8,'Color','w','FontName','Courier');
end
text(9.7,-1.1,'SPACE to pause','FontSize',8,'Color','w','FontName','Courier');

%
% MAIN LOOP
%
pause(1)
while scoreL ~= 11 && scoreR ~= 11 %keeps the loop going as long as no one has won yet
    
    corL = 1.2; %coefficient of restitution for left paddle
    corR = 1.2; %coefficient of restitution for right paddle
    leftSize = 1;
    rightSize = 1;
    paddleSpeedL = 50;
    paddleSpeedR = 50;
    loop = 0;
    round = 0;
    upgradable = 1;
    upgradeState = [6 5 0 0];
    upgradeActive = 0;
    while round == 0 %keeps the loop going until a point is scored
        
        loop = loop + 1; %loop counter for upgrades
        
        %Check if upgrades are active
        if upgradeActive == 1
            corL = .5;
            corR = 2;
            set (textUpgrade,'string','Bounce Advantage!');
        elseif upgradeActive == 2
            paddleSpeedL = 35;
            paddleSpeedR = 65;
            set (textUpgrade,'string','Faster Paddle!');
        elseif upgradeActive == 3
            rightSize = 2;
            set (textUpgrade,'string','Larger Paddle!');
        elseif upgradeActive == 4
            corL = 2;
            corR = .5;
            set (textUpgrade,'string','Bounce Advantage!');
        elseif upgradeActive == 5
            leftSize = 2;
            set (textUpgrade,'string','Larger Paddle!');
        elseif upgradeActive == 6
            paddleSpeedL = 65;
            paddleSpeedR = 35;
            set (textUpgrade,'string','Faster Paddle!');
        elseif upgradeActive == 0
            set (textUpgrade,'string',' ');
            corL = 1.1;
            corR = 1.1;
            paddleSpeedL = 50;
            paddleSpeedR = 50;
            leftSize = 1;
            rightSize = 1;
        end
        
        %RELEASE UPGRADES
        if rem(loop,1000) == 0
            upgradable = 1;
            upgradeActive = 0;
            if randi(2) == 1
                upgradeState = [6 5 20 randi([-10 10])];
            elseif randi(2) == 2
                upgradeState = [6 5 -20 randi([-10 10])];
            end
        end
        
        %update Ball State
        ballState = updateBallState(ballState,dt,corL,corR,leftPos,leftSize,rightPos,rightSize);
        
        %Update Upgrade State
        upgradeState = updateBallState(upgradeState,dt,corL,corR,leftPos,leftSize,rightPos,rightSize);
        
        %Check for upgrade collision
        if upgradeState(1) <= 1.1 && upgradeState(1) >=.9 && leftPos<=5 && leftPos>=5-leftSize && upgradable == 1
            upgradeActive = 3+randi(3);
            upgradable = 0;
            upgradeState = [.1 5 0 0];
            sound(upg);
        elseif upgradeState(1) >= 10.9 && upgradeState(1) <=11.1 && rightPos<=5 && rightPos>=5-rightSize && upgradable == 1
            upgradeActive = randi(3);
            upgradable = 0;
            upgradeState = [11.9 5 0 0];
            sound(upg);
        elseif upgradeState(1) >= 10.9 || upgradeState(1) <= 1.1
            upgradeState = [6 5 0 0];
        end
        
        %Update Paddles
        if gameMode == 1
            leftPos = autoControl(leftPos,leftSize,paddleSpeedL,ballState,dt);
        elseif gameMode == 2
            leftPos = updateLeftPaddle(controlL,leftPos,leftSize,dt);
        end
        rightPos = updateRightPaddle(controlR,rightPos,rightSize,dt);
        
        %Update graphics
        set (h,'XData',ballState(1));
        set (h,'YData',ballState(2));
        set (u,'XData',upgradeState(1));
        set (f, 'KeyPressFcn', @Keyboardcallback);
        set (f, 'KeyReleaseFcn', @Keyreleasecallback);
        set (leftPaddle,'YData',[leftPos leftPos+leftSize]);
        set (rightPaddle,'YData',[rightPos rightPos+rightSize]);
        
        %Check if a point was scored
        if ballState(1) < .5 || ballState(1) > 11.5
            round = 1;
            if ballState(1) < .5
                scoreR = scoreR + 1;
                ballState = [6 5 -25 randi([-20 20])];
                sound(upg);
            elseif ballState(1) > 11.5
                scoreL = scoreL + 1;
                ballState = [6 5 25 randi([-20 20])];
                sound(upg);
            end
        end
        pause(.01)
        
        %Regulate Velocity
        if abs(ballState(3)) > 90
            if ballState(3) > 0
                ballState(3) = 90;
            elseif ballState(3) < 0
                ballState(3) = - 90;
            end
        elseif abs(ballState(3)) < 25
            if ballState(3) > 0
                ballState(3) = 25;
            elseif ballState(3) < 0
                ballState(3) = -25;
            end
        end
        
        if abs(ballState(4)) > 60
            if ballState(4) > 0
                ballState(4) = 60;
            elseif ballState(4) < 0
                ballState(4) = -60;
            elseif ballState(4) == 0
                ballState(4) = 3;
            end
        end
        
    end
    
    % Update scores
    set (leftText,'string',num2str(scoreL));
    set (rightText,'string',num2str(scoreR));
    set (h,'XData',ballState(1));
    set (h,'YData',ballState(2));
    pause(1)
    
end

text(3,5,'GAME OVER!','Color','w','FontSize',30);


%
% Helper Functions
%

%Keyboard callback functions
    function Keyboardcallback(source, eventdata)
        switch (eventdata.Character)
            case 'q'
                controlL = 1;
            case 'a'
                controlL = -1;
            case 'p'
                controlR = 1;
            case 'l'
                controlR = -1;
            otherwise
        end
    end

    function Keyreleasecallback(source,eventdata)
        switch (eventdata.Character)
            case 'q'
                controlL = 0;
            case 'a'
                controlL = 0;
            case 'p'
                controlR = 0;
            case 'l'
                controlR = 0;
            case ' '
                pauseText = text(0.2,5,'PAUSE. Press any key to continue.','Color','w','FontSize',18,'FontName','Courier');
                pause
                delete(pauseText);
            otherwise
        end
    end

%Update Ball State
    function ballState = updateBallState(ballState,dt,corL,corR,leftPos,leftSize,rightPos,rightSize)
        x = ballState(1);
        y = ballState(2);
        vx = ballState(3);
        vy = ballState(4);
        %test for floor/ceiling collision
        if (y + dt*vy) <= 0 || (y + dt*vy) >= 10
            x = x + dt*vx;
            vy = -vy;
            ballState = [x y vx vy];
        %test for left collision
        elseif (x + dt*vx) <= 1 && (y + dt*vy) >= leftPos && (y + dt*vy) <= leftPos+leftSize;
            x = 1;
            y = y + dt*vy;
            vx = -vx*(corL);
            sound(bup);
            %angle for bounce
            if (y + dt*vy) < leftPos+leftSize/16 || (y + dt*vy) > leftPos+leftSize*15/16
                vy = -vy*1.5;
            elseif (y + dt*vy) < leftPos+leftSize/4  || (y + dt*vy) > leftPos+leftSize*3/4
                vy = vy*1.5;
            end
            ballState=[x y vx vy];
        %test for right collision
        elseif (x + dt*vx) >= 11 && (y + dt*vy) >= rightPos && (y + dt*vy) <= rightPos+rightSize;
            x = 11;
            y = (y + dt*vy);
            vx = -vx*(corR);
            sound(bup);
            if (y + dt*vy) < rightPos+rightSize/16 || (y + dt*vy) > rightPos+rightSize*15/16
                vy = -vy*1.5;
            elseif (y + dt*vy) < rightPos+rightSize/4  || (y + dt*vy) > rightPos+rightSize*3/4
                vy = vy*1.5;
            end
            ballState=[x y vx vy];
        %no collision
        else
            x = x + dt*vx;
            y = y + dt*vy;
            ballState = [x y vx vy];
        end
    end


%Update Left Paddle
    function leftPos = updateLeftPaddle(controlL,leftPos,leftSize,dt)
        if controlL == 1
            if leftPos+leftSize < 10
                leftPos = leftPos + paddleSpeedL*dt;
            end
        elseif controlL == -1
            if leftPos > 0
                leftPos = leftPos - paddleSpeedL*dt;
            end
        end
    end

%Update Right Paddle
    function rightPos = updateRightPaddle(controlR,rightPos,rightSize,dt)
        if controlR == 1
            if rightPos+rightSize < 10
                rightPos = rightPos + paddleSpeedR*dt;
            end
        elseif controlR == -1
            if rightPos > 0
                rightPos = rightPos - paddleSpeedR*dt;
            end
        end
    end

%Automated Paddle Control for Single Player Mode
    function leftPos = autoControl(leftPos,leftSize,paddleSpeedL,ballState,dt)
        if leftPos+leftSize/2 > ballState(2)+.4
            if leftPos > 0
                leftPos = leftPos - paddleSpeedL*dt;
            end
        elseif leftPos+leftSize/2 < ballState(2)-.4
            if leftPos+leftSize < 10
                leftPos = leftPos + paddleSpeedL*dt;
            end
        end
    end
end

        
        
        
        
        
        
        
        
        
