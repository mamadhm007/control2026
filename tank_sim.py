import sys
import subprocess
import time
import random

# --- نصب خودکار کتابخانه ---
def install_and_import(package):
    try:
        return __import__(package)
    except ImportError:
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            return __import__(package)
        except:
            sys.exit(1)

pygame = install_and_import('pygame')
from pygame.locals import *

# --- تنظیمات اولیه ---
pygame.init()
WIDTH, HEIGHT = 900, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("شبیه‌سازی فشار قوی (High Pressure Discharge)")
clock = pygame.time.Clock()
FONT = pygame.font.SysFont('Arial', 18, bold=True)
BIG_FONT = pygame.font.SysFont('Arial', 24, bold=True)

# --- رنگ‌ها ---
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
WATER_BLUE = (30, 144, 255)
DEEP_WATER = (0, 100, 200) # رنگ آب پرفشار
TANK_GREY = (220, 220, 220)
PIPE_DARK = (60, 60, 60)
RED = (220, 50, 50)
GREEN = (0, 200, 0)
ORANGE = (255, 140, 0)

# --- پارامترهای سیستم ---
TIME_SCALE = 20.0 
dt = 0.05

Tau = 200.0       
K_plant = 20.0    
# ضرایب PID (کمی تقویت شده برای جبران فشار بالا)
Kp = 30.0
Ki = 25.0

# --- تنظیم قدرت تخلیه ---
# این عدد تعیین میکنه چقدر آب با شدت خالی بشه
# قبلا 3 بود، الان 15 است (5 برابر فشار بیشتر)
CONSUMER_STRENGTH = 15.0 

# --- متغیرهای شبیه‌سازی ---
h = 0.0           
u_I = 0.0         
setpoint = 10.0   
valve_in = 0.0    
is_consuming = False   
splash_particles = [] # برای افکت پاشش آب

# --- تنظیمات گرافیکی ---
TANK_X, TANK_Y = 350, 100
TANK_W, TANK_H = 200, 400
MAX_H_DISPLAY = 15.0 
PPM = TANK_H / MAX_H_DISPLAY 
DISCHARGE_PIPE_H = 1.0 

running = True
while running:
    screen.fill(WHITE)

    # 1. رویدادها
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_r: 
                h = 0.0; u_I = 0.0; is_consuming = False
            if event.key == pygame.K_SPACE or event.key == pygame.K_c: 
                is_consuming = not is_consuming

    # 2. محاسبات فیزیک
    steps_per_frame = int(TIME_SCALE) 
    for _ in range(steps_per_frame):
        error = setpoint - h
        
        # PID
        u_I += Ki * error * dt
        if u_I > 35: u_I = 35 # انتگرال‌گیر قوی‌تر
        if u_I < -35: u_I = -35
        
        u_raw = Kp * error + u_I
        u = max(0.0, min(1.0, u_raw))
        valve_in = u
        
        # تخلیه طبیعی (آرام)
        if h > DISCHARGE_PIPE_H:
            discharge_rate = (h - DISCHARGE_PIPE_H) / Tau
        else:
            discharge_rate = 0.0
            
        # تخلیه مصرف‌کننده (فشار قوی)
        # فرمول: Strength / Tau
        consumption_rate = CONSUMER_STRENGTH / Tau if is_consuming else 0.0
        
        dh = ((K_plant * u) / Tau) - discharge_rate - consumption_rate
        
        h += dh * dt
        if h < 0: h = 0

    # 3. رسم گرافیکی

    title = BIG_FONT.render("High Pressure Demand Simulation", True, BLACK)
    screen.blit(title, (WIDTH//2 - title.get_width()//2, 20))

    # تانک
    pygame.draw.rect(screen, TANK_GREY, (TANK_X, TANK_Y, TANK_W, TANK_H))
    pygame.draw.rect(screen, BLACK, (TANK_X, TANK_Y, TANK_W, TANK_H), 4)

    # آب
    water_h_px = int(h * PPM)
    draw_h = min(water_h_px, TANK_H)
    pygame.draw.rect(screen, WATER_BLUE, (TANK_X, TANK_Y + TANK_H - draw_h, TANK_W, draw_h))

    # خط هدف
    sp_y = TANK_Y + TANK_H - int(setpoint * PPM)
    pygame.draw.line(screen, RED, (TANK_X - 20, sp_y), (TANK_X + TANK_W + 20, sp_y), 3)
    screen.blit(FONT.render("10m", True, RED), (TANK_X + TANK_W + 25, sp_y - 10))

    # ورودی (چپ)
    pygame.draw.rect(screen, PIPE_DARK, (TANK_X - 60, TANK_Y + 50, 60, 30))
    valve_w = int(valve_in * 60)
    # تغییر رنگ شیر ورودی به قرمز وقتی تحت فشار است (100%)
    inlet_color = RED if valve_in > 0.95 else GREEN
    pygame.draw.rect(screen, inlet_color, (TANK_X - 60, TANK_Y + 55, valve_w, 20))
    screen.blit(FONT.render(f"Inlet: {int(valve_in*100)}%", True, BLACK), (TANK_X - 120, TANK_Y + 20))

    # خروجی طبیعی (بالا)
    discharge_y = TANK_Y + TANK_H - int(DISCHARGE_PIPE_H * PPM) - 15
    pygame.draw.rect(screen, PIPE_DARK, (TANK_X + TANK_W, discharge_y, 40, 30))
    if h > DISCHARGE_PIPE_H:
        pygame.draw.rect(screen, WATER_BLUE, (TANK_X + TANK_W, discharge_y + 15, 40, 5))
        pygame.draw.rect(screen, WATER_BLUE, (TANK_X + TANK_W + 40, discharge_y + 15, 5, 100))

    # --- مصرف کننده فشار قوی (پایین) ---
    consumer_y = TANK_Y + TANK_H - 50
    pygame.draw.rect(screen, PIPE_DARK, (TANK_X + TANK_W, consumer_y, 60, 40)) # لوله ضخیم‌تر
    
    if is_consuming:
        # رسم جریان آب ضخیم و پرفشار
        pygame.draw.rect(screen, DEEP_WATER, (TANK_X + TANK_W + 60, consumer_y + 5, 30, 200))
        
        # افکت پاشش آب (Particles)
        for _ in range(5):
            px = TANK_X + TANK_W + 75 + random.randint(-20, 20)
            py = consumer_y + 200 + random.randint(0, 30)
            pygame.draw.circle(screen, DEEP_WATER, (px, py), random.randint(2, 5))

        label = BIG_FONT.render("HIGH FLOW!", True, RED)
        screen.blit(label, (TANK_X + TANK_W + 100, consumer_y))
    else:
        # وقتی بسته است
        pygame.draw.circle(screen, RED, (TANK_X + TANK_W + 30, consumer_y + 20), 8)

    screen.blit(FONT.render("Press SPACE for Heavy Load", True, BLACK), (TANK_X + TANK_W + 10, consumer_y + 40))

    # پنل اطلاعات
    info_y = HEIGHT - 80
    screen.blit(BIG_FONT.render(f"Height: {h:.2f} m", True, BLACK), (50, info_y))
    
    if is_consuming:
        if valve_in > 0.99:
            status = "CRITICAL LOAD: VALVE MAXED!"
            clr = RED
        else:
            status = "Compensating..."
            clr = ORANGE
    elif abs(setpoint - h) < 0.1:
        status = "STABLE"
        clr = GREEN
    else:
        status = "Adjusting..."
        clr = BLACK
        
    screen.blit(BIG_FONT.render(status, True, clr), (50, info_y + 30))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
sys.exit()