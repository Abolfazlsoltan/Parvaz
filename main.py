from kivy.app import App
from kivy.core.window import Window
from kivy.clock import Clock
from kivy.uix.widget import Widget
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.button import Button
from kivy.graphics import Color, Rectangle
from kivy.metrics import dp
from game import NeonSurvivor

class NeonApp(App):
    title = "NEON SURVIVOR"
    def build(self):
        root = FloatLayout()
        self.game = NeonSurvivor()
        root.add_widget(self.game)
        self.pause_btn = Button(text="Ⅱ", size_hint=(None,None), size=(dp(54),dp(48)),
            pos_hint={"right":.98,"top":.98}, background_color=(.08,.35,.48,.95))
        self.pause_btn.bind(on_release=lambda *_: self.game.toggle_pause())
        root.add_widget(self.pause_btn)
        Window.bind(on_keyboard=self.on_keyboard)
        return root

    def on_keyboard(self, window, key, *args):
        if key == 27:
            if self.game.state == "play":
                self.game.toggle_pause()
            else:
                self.game.show_menu()
            return True
        return False

if __name__ == "__main__":
    NeonApp().run()
