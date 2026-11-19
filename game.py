import math, random, json, os
from kivy.uix.widget import Widget
from kivy.app import App
from kivy.clock import Clock
from kivy.graphics import Color, Ellipse, Line, Rectangle, Triangle
from kivy.core.text import Label as CoreLabel
from kivy.metrics import dp
from kivy.utils import get_color_from_hex

BG = "#080B18"
CYAN = "#45E8FF"
PINK = "#FF477E"
GOLD = "#FFD166"
PURPLE = "#B36BFF"
GREEN = "#65F59A"

def rgba(h, a=1):
    c=get_color_from_hex(h); return (*c[:3],a)

class NeonSurvivor(Widget):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.state="menu"; self.paused=False; self.high=0
        self.load_high(); self.bind(size=self.draw)
        self.reset(); Clock.schedule_interval(self.update,1/60)

    def load_high(self):
        try:
            with open(os.path.join(App.get_running_app().user_data_dir,'record.json')) as f:
                self.high=json.load(f).get('high',0)
        except Exception: pass

    def save_high(self):
        try:
            from kivy.app import App
            with open(os.path.join(App.get_running_app().user_data_dir,'record.json'),'w') as f:
                json.dump({'high':self.high},f)
        except Exception: pass

    def reset(self):
        self.player=[.5,.5]; self.enemies=[]; self.bullets=[]; self.particles=[]; self.powerups=[]
        self.score=0; self.lives=3; self.elapsed=0; self.spawn=0; self.shot=0
        self.dash=0; self.dash_cd=0; self.inv=0; self.shield=False; self.triple=0
        self.joy=None; self.move=[0,0]; self.last_dt=1/60

    def map_pos(self,p):
        return (self.x+p[0]*self.width,self.y+p[1]*self.height)
    def norm(self,x,y):
        m=math.hypot(x,y)
        return (x/m,y/m) if m>.001 else (0,0)
    def burst(self,p,color,n=12):
        for _ in range(n):
            a=random.random()*math.tau; s=random.uniform(.08,.35)
            self.particles.append([p[0],p[1],math.cos(a)*s,math.sin(a)*s,random.uniform(.25,.6),color])

    def start(self):
        self.reset(); self.state="play"; self.draw()
    def show_menu(self):
        self.state="menu"; self.paused=False; self.draw()
    def toggle_pause(self):
        if self.state=="play": self.paused=not self.paused; self.draw()
        elif self.state in ("menu","over"): self.start()

    def dash_move(self):
        if self.dash_cd<=0 and self.state=="play" and not self.paused:
            d=self.norm(*self.move)
            if d==(0,0) and self.enemies:
                e=min(self.enemies,key=lambda z:(z[0]-self.player[0])**2+(z[1]-self.player[1])**2)
                d=self.norm(e[0]-self.player[0],e[1]-self.player[1])
            if d==(0,0): d=(1,0)
            self.dash=0.18; self.dash_cd=1.15; self.inv=.35
            self.move=list(d); self.burst(self.player,CYAN,22)

    def on_touch_down(self,t):
        if self.state!="play":
            self.start(); return True
        if self.paused:
            self.paused=False; return True
        lx=(t.x-self.x)/max(1,self.width); ly=(t.y-self.y)/max(1,self.height)
        if lx>.72 and ly<.28:
            self.dash_move(); return True
        if lx<.55 and ly<.72:
            self.joy=t.uid; self.joy_origin=(lx,ly); self.set_joy(lx,ly); return True
        self.dash_move(); return True

    def set_joy(self,x,y):
        ox,oy=self.joy_origin
        self.move=list(self.norm(max(-1,min(1,(x-ox)*3.0)),max(-1,min(1,(y-oy)*3.0))))
    def on_touch_move(self,t):
        if self.joy==t.uid:
            self.set_joy((t.x-self.x)/max(1,self.width),(t.y-self.y)/max(1,self.height)); return True
    def on_touch_up(self,t):
        if self.joy==t.uid: self.joy=None; self.move=[0,0]; return True

    def update(self,dt):
        dt=min(dt,.04)
        if self.state!="play" or self.paused: return
        self.elapsed+=dt; self.spawn-=dt; self.shot-=dt
        self.dash=max(0,self.dash-dt); self.dash_cd=max(0,self.dash_cd-dt)
        self.inv=max(0,self.inv-dt); self.triple=max(0,self.triple-dt)
        speed=1.15 if self.dash>0 else .48
        self.player[0]=max(.035,min(.965,self.player[0]+self.move[0]*speed*dt))
        self.player[1]=max(.07,min(.93,self.player[1]+self.move[1]*speed*dt))
        if self.spawn<=0:
            for _ in range(1+int(self.elapsed//35)):
                side=random.randrange(4); v=random.random()
                p=[(v,-.04),(1.04,v),(v,1.04),(-.04,v)][side]
                kind=random.choices(["chaser","dart","tank"],[.65,.25,.10 if self.elapsed>25 else .01])[0]
                hp={"chaser":1,"dart":1,"tank":5}[kind]
                self.enemies.append([p[0],p[1],kind,hp,random.random()*6])
            self.spawn=max(.28,1.15-self.elapsed*.009)
        if self.shot<=0 and self.enemies:
            e=min(self.enemies,key=lambda z:(z[0]-self.player[0])**2+(z[1]-self.player[1])**2)
            d=self.norm(e[0]-self.player[0],e[1]-self.player[1])
            angles=(-.18,0,.18) if self.triple>0 else (0,)
            for a in angles:
                c,s=math.cos(a),math.sin(a); dx=d[0]*c-d[1]*s; dy=d[0]*s+d[1]*c
                self.bullets.append([self.player[0],self.player[1],dx*1.5,dy*1.5,1.1])
            self.shot=.22
        for b in self.bullets: b[0]+=b[2]*dt; b[1]+=b[3]*dt; b[4]-=dt
        for e in self.enemies:
            d=self.norm(self.player[0]-e[0],self.player[1]-e[1]); sp={"chaser":.19,"dart":.36,"tank":.11}[e[2]]*(1+self.elapsed/240)
            e[0]+=d[0]*sp*dt; e[1]+=d[1]*sp*dt; e[4]+=dt*2
        for b in self.bullets:
            if b[4]<=0: continue
            for e in self.enemies:
                if e[2] and math.hypot(b[0]-e[0],b[1]-e[1])<{"chaser":.035,"dart":.025,"tank":.055}[e[2]]:
                    b[4]=0; e[3]-=1
                    if e[3]<=0:
                        kind=e[2]; e[2]=None; self.score+={"chaser":10,"dart":15,"tank":50}[kind]
                        self.burst(e[:2],{"chaser":PINK,"dart":GOLD,"tank":PURPLE}[kind])
                        if random.random()<.09: self.powerups.append([e[0],e[1],random.choice(["shield","triple","nova"]),9])
                    break
        for e in self.enemies:
            if not e[2]: continue
            if math.hypot(e[0]-self.player[0],e[1]-self.player[1])<.045:
                if self.dash>0: e[2]=None; self.score+=10; self.burst(e[:2],CYAN)
                elif self.inv<=0:
                    if self.shield: self.shield=False
                    else: self.lives-=1
                    self.inv=1.25; e[2]=None; self.burst(self.player,PINK,20)
                    if self.lives<=0:
                        self.state="over"; self.high=max(self.high,self.score); self.save_high()
        for u in self.powerups:
            u[3]-=dt
            if math.hypot(u[0]-self.player[0],u[1]-self.player[1])<.055:
                if u[2]=="shield": self.shield=True
                elif u[2]=="triple": self.triple=10
                else:
                    for e in self.enemies:
                        if e[2]: e[2]=None; self.score+=10; self.burst(e[:2],GOLD,8)
                u[3]=0
        for p in self.particles:
            p[0]+=p[2]*dt; p[1]+=p[3]*dt; p[4]-=dt
        self.bullets=[b for b in self.bullets if b[4]>0 and -.1<b[0]<1.1 and -.1<b[1]<1.1]
        self.enemies=[e for e in self.enemies if e[2]]
        self.powerups=[u for u in self.powerups if u[3]>0]
        self.particles=[p for p in self.particles if p[4]>0]
        self.draw()

    def label(self,txt,x,y,size,color):
        from kivy.core.text import Label
        lab=Label(text=txt,font_size=dp(size),bold=True,color=rgba(color),size_hint=(None,None))
        lab.texture_update(); w,h=lab.texture_size
        lab.pos=(self.x+x*self.width-w/2,self.y+y*self.height-h/2); lab.size=(w,h); lab.canvas.ask_update()
        self.canvas.add(Color(1,1,1,1)); self.canvas.add(Rectangle(texture=lab.texture,pos=lab.pos,size=lab.size))

    def draw(self,*_):
        if not self.width or not self.height: return
        self.canvas.clear()
        with self.canvas:
            Color(*rgba(BG)); Rectangle(pos=self.map_pos((0,0)),size=self.size)
            Color(*rgba("#141A32"))
            for i in range(1,12):
                x=self.x+self.width*i/12; Line(points=[x,self.y,x,self.top],width=dp(.5))
            for i in range(1,8):
                y=self.y+self.height*i/8; Line(points=[self.x,y,self.right,y],width=dp(.5))
            for p in self.particles:
                Color(*rgba(p[5],max(0,p[4]*1.8))); Ellipse(pos=self.map_pos((p[0]-.006,p[1]-.006)),size=(dp(5),dp(5)))
            for b in self.bullets:
                Color(*rgba(CYAN)); Ellipse(pos=self.map_pos((b[0]-.007,b[1]-.007)),size=(dp(8),dp(8)))
            for e in self.enemies:
                c={"chaser":PINK,"dart":GOLD,"tank":PURPLE}[e[2]]
                x,y=self.map_pos(e[:2]); r=dp({"chaser":12,"dart":9,"tank":21}[e[2]])
                Color(*rgba(c)); Line(circle=(x,y,r),width=dp(2)); Ellipse(pos=(x-r*.35,y-r*.35),size=(r*.7,r*.7))
            x,y=self.map_pos(self.player); r=dp(14)
            Color(*rgba(CYAN, .25)); Ellipse(pos=(x-r*1.8,y-r*1.8),size=(r*3.6,r*3.6))
            Color(*rgba(CYAN)); Line(circle=(x,y,r),width=dp(2)); Ellipse(pos=(x-r*.45,y-r*.45),size=(r*.9,r*.9))
            if self.shield:
                Color(*rgba(GREEN)); Line(circle=(x,y,dp(24)),width=dp(2))
            Color(*rgba("#25324D")); Line(points=[self.x+dp(18),self.y+dp(24),self.x+dp(138),self.y+dp(24)],width=dp(5))
            Color(*rgba(CYAN if self.dash_cd<=0 else "#55718B")); Line(points=[self.x+dp(18),self.y+dp(24),self.x+dp(18)+dp(120)*(1-self.dash_cd/1.15),self.y+dp(24)],width=dp(5))
        if self.state=="play":
            self.label(f"SCORE  {self.score}",.18,.96,17,"#FFFFFF")
            self.label(f"BEST {self.high}",.18,.91,11,"#A5B4D6")
            self.label("♥ "*self.lives,.82,.96,18,PINK)
            self.label("DASH",.12,.045,10,CYAN)
            if self.triple>0: self.label(f"TRIPLE {self.triple:.0f}s",.8,.06,11,GREEN)
            self.label("DRAG LEFT SIDE TO MOVE   •   TAP RIGHT TO DASH",.5,.11,10,"#8191B5")
        if self.state=="menu":
            self.label("NEON",.5,.68,55,CYAN); self.label("SURVIVOR",.5,.57,34,"#FFFFFF")
            self.label("SURVIVE THE NEON SWARM",.5,.47,14,PURPLE)
            self.label("TOUCH ANYWHERE TO START",.5,.31,16,GOLD)
            self.label(f"BEST SCORE  {self.high}",.5,.23,13,"#A5B4D6")
            self.label("MOVE: DRAG LEFT  |  DASH: TAP RIGHT",.5,.14,11,"#A5B4D6")
        elif self.state=="over":
            self.label("GAME OVER",.5,.65,38,PINK); self.label(f"SCORE  {self.score}",.5,.52,24,"#FFFFFF")
            self.label(f"RECORD  {self.high}",.5,.43,18,GOLD); self.label("TAP TO PLAY AGAIN",.5,.28,16,CYAN)
        elif self.paused:
            self.label("PAUSED",.5,.56,38,"#FFFFFF"); self.label("TAP TO RESUME",.5,.42,15,CYAN)
