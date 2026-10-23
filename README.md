# 🚀 ROBLOX UI STUDIO — 80 THƯ VIỆN UI SCRIPT ROBLOX ĐỘC LẬP & BỘ CHUYỂN ĐỔI CHUẨN HOÁ HTML/CSS/JS SANG LUA

> **Một hệ thống thiết kế toàn diện gồm 80 thư viện UI script Roblox phong cách hoàn toàn độc lập, tinh chỉnh màu sắc trực tiếp trên nền tảng web, xuất mã nguồn Luau tự động với bộ chuẩn hoá độ trung khớp 100% (1:1 Fidelity Verification).**

---

## 🌟 TỔNG QUAN TÍNH NĂNG ĐỘT PHÁ

1. **80 Phong cách Thiết kế Hoàn toàn Độc lập (80 Distinct Styles)**:
   - Được phân chia thành 8 đại danh mục mỹ thuật: **Cyberpunk & Sci-Fi (12)**, **Glass & Neumorphism (10)**, **Brutalism & Neo-Pop (8)**, **Gaming & Anime RPG (12)**, **Retro OS & Vintage (10)**, **Luxury & Royalty (10)**, **Nature & Elements (10)**, và **Developer & Void (8)**.
   - Mỗi phong cách sở hữu toàn bộ Design Tokens riêng: Bảng màu Hex/RGBA, Font chữ (Enum.Font), Bo góc (UICorner), Viền nổi (UIStroke), Đổ bóng (Shadow/Glow), Hiệu ứng chuyển động (TweenService Easing), và Hồ sơ âm thanh tương tác (Web Audio API Synthesizer).

2. **Bộ công cụ Chuẩn hoá HTML/CSS/JS sang Luau (Universal Transpiler Engine)**:
   - Đảm bảo **chính xác 100%**: Trên web mẫu hiển thị như thế nào thì khi xuất ra mã Luau trong Roblox Studio sẽ giống hệt như thế.
   - Tự động chuyển đổi các thuộc tính:
     - `background-color` & `color` ➔ `Color3.fromRGB(...)` & `BackgroundTransparency = 1 - alpha`
     - `border-radius: Xpx` ➔ `UICorner.CornerRadius = UDim.new(0, X)`
     - `border: Xpx solid C` ➔ `UIStroke.Thickness = X`, `UIStroke.Color = Color3.fromRGB(...)`
     - `box-shadow` / `glow` ➔ `ImageLabel` 9-slice shadow / `UIStroke` glow
     - `transition` / `animation` ➔ `TweenService:Create(...)` với các `Enum.EasingStyle` (Back, Quart, Sine, Linear)
     - `font-family` ➔ Tự động ánh xạ chuẩn xác sang `Enum.Font` của Roblox (`GothamBold`, `SciFi`, `Arcade`, `Fondamento`, `Code`, `FredokaOne`).

3. **Giao diện Web Live Customizer & Viewport Thực tế**:
   - Bộ giả lập cửa sổ Roblox (`ScreenGui`, `CanvasGroup`, `Header`, `Sidebar`, `ContentArea`) cho phép tương tác trực tiếp:
     - **Nút bấm (Buttons)**: Hiệu ứng co giãn, phản quang, kích hoạt hành động.
     - **Công tắc (Toggle Switch)**: Hiệu ứng trượt bi mượt mà, chuyển đổi trạng thái Bật/Tắt.
     - **Thanh trượt (Slider)**: Kéo thả chuột mượt mà, hiển thị giá trị thời gian thực.
     - **Hộp nhập văn bản (Input Text)**: Bắt sự kiện Enter, viền sáng khi trỏ chuột.
     - **Menu lựa chọn (Dropdown)**: Đóng/mở hoạt họa, chọn phần tử linh hoạt.
     - **Phím tắt (Keybind)**: Bắt phím bấm trực tiếp từ bàn phím để gán `Enum.KeyCode`.
     - **Hệ thống thông báo (Notification / Toast)**: Xếp chồng tự động, thanh tiến trình màu sắc, tự hủy mượt mà.
   - Bảng điều khiển màu sắc trực tiếp (Real-time Color Picker): Thay đổi mã màu hex là giao diện web và mã Luau tự động cập nhật ngay tức khắc.

4. **Bộ kiểm thử Tự động (Automated Fidelity Test Suite)**:
   - Tích hợp công cụ xác thực `UIStudioValidator` kiểm tra 80/80 phong cách.
   - Xác nhận 100% vượt qua các bài kiểm tra toán học và thuộc tính đồ họa.

5. **Hệ thống Âm thanh Phản hồi (Web Audio API Synthesizer)**:
   - Tích hợp bộ phát âm thanh vi mô (Cyber beep, 8-bit retro, Click cơ học, Chime ma thuật) không cần file audio ngoài, hoạt động mượt mà với độ trễ bằng 0.

---

## 🎨 DANH SÁCH 80 PHONG CÁCH THIẾT KẾ ĐỘC LẬP

### 1. Cyberpunk & Sci-Fi (12 Styles)
- `cyberpunk-2077`: Cyberpunk 2077 Night City (Vàng neon `#fcee0a` & xanh cyan `#00f0ff`, vạch cảnh báo)
- `synthwave-80s`: Synthwave Neon Outrun 1984 (Hồng tím magenta `#ff007f`, cyan, hoàng hôn 80s)
- `matrix-terminal`: Matrix Digital Rain Terminal (Xanh phosphor CRT `#00ff66` trên nền đen)
- `amber-crt-hacker`: Amber CRT Retro Hacker (Màn hình hổ phách cổ điển thập niên 70 `#ffb000`)
- `starfield-deepspace`: Starfield Deep Space HUD (Phi thuyền không gian sâu, xanh than `#0f172a` & titan)
- `tactical-apex-hud`: Tactical Apex Vanguard HUD (Quân sự công nghệ cao, cam `#ff5500`, góc cắt vát)
- `solar-plasma-flare`: Solar Plasma Flare Core (Năng lượng plasma cam bốc cháy `#ff6a00` & đá núi lửa)
- `quantum-flux-violet`: Quantum Flux Singularity (Vật lý lượng tử tím điện trường `#a855f7` & tia cyan)
- `high-voltage-arc`: High Voltage Electric Arc (Tia chớp điện cao thế `#00e5ff`, giật sắc nét)
- `cyber-samurai-neo`: Cyber Samurai Neo-Tokyo (Đỏ kiếm katana `#ff1744` trên nền mực đen)
- `syndicate-corpo-ice`: Syndicate Megacorp Executive (Tập đoàn tài phiệt tương lai, xám băng `#00b4d8`)
- `ghost-shell-ai`: Ghost Shell Cybernetic Net (Dây quang thần kinh xanh ngọc `#10b981`)

### 2. Glass & Neumorphism (10 Styles)
- `glass-frosted-aura`: Glassmorphism Frosted Aura (Kính mờ xuyên thấu siêu thực với viền phản quang trắng)
- `glass-prism-iridescent`: Glass Prism Iridescent Glow (Lăng kính khúc xạ sắc màu cầu vồng huyền ảo)
- `neumorph-dark-concave`: Neumorphism Dark Tactile (Nút bấm xúc giác lồi lõm dập nổi)
- `neumorph-light-soft`: Neumorphism Soft Marshmallow (Trắng ngà êm ái như kẹo dẻo với bóng kép mềm mại)
- `claymorphism-3d-toy`: Claymorphism 3D Playful Toy (Đất nặn 3D phúng phính, góc bo 24px)
- `nordic-frost-minimal`: Nordic Frost Alpine White (Phong cách Bắc Âu tinh khiết như tuyết băng)
- `swiss-minimalist-grid`: Swiss International Typographic (Trường phái Thụy Sĩ, tương phản typographic)
- `liquid-mercury-chrome`: Liquid Mercury Metallic Chrome (Thủy ngân lỏng kim loại bạc chrome bóng loáng)
- `aurora-borealis-polar`: Aurora Borealis Ethereal Sky (Cực quang xanh ngọc lượn sóng tím đêm)
- `bioluminescent-abyss`: Bioluminescent Abyssal Creature (Sinh vật phát quang đáy biển thẳm `#00f5d4`)

### 3. Brutalism & Neo-Pop (8 Styles)
- `neo-brutalism-pop`: Neo-Brutalism Electric Pop (Vàng chanh `#fff952`, viền đen 3px, bóng cứng 100%)
- `raw-industrial-concrete`: Raw Brutalist Heavy Concrete (Bê tông thô dã man, vạch sọc vàng đen)
- `comic-manga-action`: Comic Pop Manga Boom (Chấm halftone manga, viền mực vẽ tay mạnh mẽ)
- `y2k-cyber-millennium`: Y2K Cyber Metallic 2000 (Chrome bóng bạc, hồng fuchsia kẹo ngọt)
- `acid-biohazard-toxic`: Acid Toxic Slime Biohazard (Axit phóng xạ xanh neon `#39ff14`, cảnh báo sinh học)
- `glitch-void-corrupted`: Glitch Void Data Corruption (Tách kênh màu sắc Chromatic Aberration RGB đỏ xanh)
- `dystopian-rust-apocalypse`: Dystopian Rust Wasteland (Thế giới tận thế rỉ sét, sắt vụn hoen ố `#ea580c`)
- `monochrome-newspaper-ink`: Monochrome Ink Newspaper (Bản in báo chí đen trắng dứt khoát)

### 4. Gaming, Anime & RPG (12 Styles)
- `genshin-celestial-anime`: Genshin Celestial Teyvat (Viền dát vàng hoàng gia `#f5c563`, xanh lam huyền ảo)
- `elden-ring-dark-fantasy`: Elden Ring Tarnished Grace (Vàng ròng cổ đại phong trần `#c99e52`, đá hắc diện)
- `bloodborne-gothic-hunt`: Bloodborne Yharnam Gothic (Đêm săn đẫm máu Victoria `#a81324`, bạc cổ)
- `arcane-zaun-chemtech`: Arcane Zaun Chemtech Shimmer (Công nghệ hóa kỹ Zaun, ống đồng & dung dịch tím)
- `pixel-art-16bit-dungeon`: Pixel Art 16-Bit Retro Dungeon (Giao diện tay cầm 90s, viền pixel khối)
- `magic-runes-portal`: Mystic Arcane Rune Portal (Vòng tròn phong ấn pháp thuật phát sáng tím `#c084fc`)
- `dragon-jade-dynasty`: Imperial Dragon Jade Dynasty (Ngọc bích phương Đông dát vàng lộng lẫy `#059669`)
- `space-invader-arcade`: Space Invader Neon Arcade 1980 (Máy arcade xèng cổ với đèn led neon rực sáng)
- `mecha-gundam-titanium`: Mecha Gundam Tactical Titanium (Giáp titan trắng, xanh coban, tem cảnh báo)
- `overwatch-hero-hud`: Hero Overwatch Futuristic HUD (Góc vát xiên, thanh năng lượng cam trắng `#f99e1a`)
- `zelda-sheikah-slate`: Ancient Sheikah Slate Technology (Công nghệ cổ xưa Hyrule, ánh sáng xanh ngọc)
- `valorant-radianite-edge`: Valorant Radianite Protocol (Góc cắt xẻ 45 độ, vạch đo Radianite xanh lục)

### 5. Retro OS & Vintage (10 Styles)
- `windows-98-classic`: Windows 98 Desktop Classic (Thanh tiêu đề xanh teal `#008080`, nút vát nổi 3D bevel)
- `macos-aqua-vintage`: MacOS Aqua Jelly 2001 (Nút bấm thạch nước bóng bẩy ngọc bích `#2b7fff`)
- `gameboy-dmg-olive`: GameBoy DMG-01 Dot Matrix (Màn hình xanh ô-liu 4 sắc độ Nintendo 1989)
- `cassette-tape-lofi`: Cassette Tape Lo-Fi Cozy (Băng cassette ấm áp, giấy kraft nâu `#e0a96d`)
- `commodore-64-blue`: Commodore 64 Home Micro (Viền xanh lam đậm, nền cyan nhạt C64 năm 1982)
- `blueprint-cad-engineer`: Blueprint Architectural CAD (Bản vẽ kiến trúc xanh coban `#0a2342`, lưới mm)
- `steampunk-brass-gears`: Steampunk Brass & Copper Gears (Thời đại hơi nước, đồng thau đinh tán `#d97706`)
- `vintage-typewriter-paper`: Vintage Typewriter Parchment (Giấy da cổ điển ngả màu, vết mực gõ lách cách)
- `submarine-radar-sonar`: Submarine Sonar Radar Scan (Màn hình radar quét sóng âm đáy biển `#00ff4c`)
- `nasa-apollo-nixie`: NASA Apollo Flight Computer (Bảng điều khiển Apollo, bóng đèn Nixie cam)

### 6. Luxury & Royalty (10 Styles)
- `royal-sovereign-gold`: Royal Sovereign 24K Gold (Vàng ròng 24K nguyên chất `#e6b800` & nhung đen)
- `diamond-platinum-ice`: Diamond Platinum Facet (Bạch kim phát sáng, giác cắt kim cương lấp lánh)
- `amethyst-velvet-casino`: Amethyst Velvet Casino VIP (Nhung tím thạch anh `#d946ef` phòng VIP Monaco)
- `emerald-crown-jewel`: Emerald Crown Jewel Filigree (Ngọc lục bảo vương miện Anh `#10b981`, viền ren vàng)
- `rose-gold-haute-couture`: Rose Gold Haute Couture (Vàng hồng thời trang Paris `#f472b6` thanh lịch)
- `midnight-sapphire-star`: Midnight Sapphire Celestial (Đá sapphire lam đêm thẳm `#3b82f6` đính sao)
- `obsidian-black-monolith`: Obsidian Pure Black Monolith (Thủy tinh hắc diện OLED đen 100%)
- `vogue-editorial-fashion`: Vogue Haute Editorial Magazine (Bìa tạp chí thời trang, serif thanh mảnh)
- `champagne-yacht-club`: Champagne Gold Yacht Club (Rượu vang sâm panh sóng sánh `#fef08a`)
- `ruby-crimson-throne`: Ruby Crimson Imperial Throne (Hồng ngọc đỏ thẫm ngai vàng hoàng đế `#e11d48`)

### 7. Nature & Elements (10 Styles)
- `volcanic-magma-inferno`: Volcanic Magma Inferno Fissure (Dung nham núi lửa đỏ rực `#ff3300`)
- `glacial-ice-crystal`: Glacial Ice Crystalline Shard (Băng đăng sông băng vĩnh cửu trong suốt `#38bdf8`)
- `zen-garden-bamboo`: Zen Garden Bamboo & Slate (Đá phiến xám tro, rêu xanh `#84cc16`, cọc tre tĩnh tại)
- `desert-mirage-dune`: Desert Sahara Mirage Dunes (Cát vàng sa mạc Sahara `#f59e0b`, đất nung ấm nồng)
- `rainforest-canopy-green`: Amazon Rainforest Canopy Wild (Tán rừng nhiệt đới Amazon bạt ngàn sương `#22c55e`)
- `deep-ocean-trench`: Mariana Trench Deep Abyss (Rãnh biển sâu u tối `#0ea5e9`, đốm sáng phù du)
- `cherry-blossom-sakura`: Sakura Petal Spring Breeze (Cánh hoa anh đào rơi gió xuân `#f472b6`)
- `autumn-harvest-amber`: Autumn Maple Harvest Glow (Mùa thu lá phong rực đỏ cam `#ea580c`)
- `thunderstorm-tempest`: Thunderstorm Tempest Blitz (Bão sấm sét trời tím đen, sét vàng `#eab308`)
- `ethereal-cotton-cloud`: Ethereal Pastel Cloud Dream (Tầng mây kẹo bông gòn hoa oải hương `#c084fc`)

### 8. Developer & Void (8 Styles)
- `dracula-official-theme`: Dracula Vampire Pro Theme (Tím `#bd93f9`, hồng neon `#ff79c6`, cyan `#8be9fd`)
- `monokai-pro-cyber`: Monokai Pro Cyber Spectrum (Vàng `#ffd866`, xanh `#a9dc76`, hồng `#ff6188`)
- `nord-polar-twilight`: Nord Arctic Polar Twilight (Bắc Cực trầm lắng `#88c0d0`, bảo vệ thị giác)
- `catppuccin-mocha-lavender`: Catppuccin Mocha Lavender (Cà phê kem ngọt ngào Neovim `#cba6f7`)
- `arasaka-cyber-corp-red`: Arasaka Corp Red Authority (Đỏ thẫm quyền lực `#e11d48`, giám sát tối cao)
- `holo-shield-forcefield`: Holo-Shield Defense Matrix (Lưới khiên chắn năng lượng lục giác `#14b8a6`)
- `quantum-singularity-void`: Quantum Singularity Event Horizon (Chân trời sự kiện hố đen, đĩa bồi tụ `#f59e0b`)
- `omni-chameleon-reactive`: Omni-Chameleon Reactive Spectrum (Động cơ RGB đa phổ biến sắc theo âm thanh)

---

## 🛠️ CÁCH SỬ DỤNG MÃ NGUỒN LUAU TRONG ROBLOX STUDIO

### Cách 1: Chạy trực tiếp qua LocalScript
1. Mở **Roblox Studio**.
2. Trong cửa sổ **Explorer**, điều hướng tới `StarterPlayer` ➔ `StarterPlayerScripts` (hoặc `StarterGui`).
3. Nhấp chuột phải chọn **Insert Object** ➔ **LocalScript**.
4. Mở giao diện web tại `http://localhost:8080`, chọn phong cách bạn yêu thích, bấm **"Sao chép Lua"** (hoặc mở file đã xuất `.lua`).
5. Dán toàn bộ mã nguồn vào LocalScript và nhấn **Play (F5)**.

### Cách 2: Gọi thư viện qua API Modular
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/<YOUR_USER>/UI-Library/main/lua-engine/RobloxUILib_Universal.lua"))()

-- 1. Khởi tạo Cửa sổ giao diện
local Window = Library:CreateWindow({
    Title = "NEON VANGUARD HUB",
    Subtitle = "Cyberpunk 2077 Edition",
    Size = UDim2.new(0, 560, 0, 420)
})

-- 2. Tạo các Tab chức năng
local MainTab = Window:CreateTab("Chính")
local CombatTab = Window:CreateTab("Chiến đấu")

-- 3. Tạo Nút bấm (Button)
MainTab:CreateButton({
    Name = "Kích hoạt chức năng",
    Callback = function()
        print("Đã thực thi Button!")
    end
})

-- 4. Tạo Công tắc (Toggle)
CombatTab:CreateToggle({
    Name = "Tự động nhắm mục tiêu (Aimbot)",
    Default = false,
    Callback = function(state)
        print("Aimbot:", state)
    end
})

-- 5. Tạo Thanh trượt (Slider)
CombatTab:CreateSlider({
    Name = "Tốc độ di chuyển (WalkSpeed)",
    Min = 16,
    Max = 250,
    Default = 60,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

-- 6. Gửi thông báo hệ thống (Notification)
Library:Notify({
    Title = "Khởi chạy thành công!",
    Content = "Thư viện giao diện đã sẵn sàng hoạt động.",
    Type = "success",
    Duration = 4
})
```

---

## 💻 CHẠY TRANG WEB TRỰC TIẾP TRÊN MÁY TÍNH

Dự án được xây dựng bằng công nghệ thuần túy **Vanilla HTML5, CSS3 và ES6 JavaScript** (không cần cài đặt `npm` hay bất kỳ thư viện trung gian cồng kềnh nào):

```bash
# Sử dụng Python HTTP Server có sẵn
python -m http.server 8080
```
Sau đó mở trình duyệt truy cập: `http://localhost:8080` (hoặc mở trực tiếp file `index.html`).

---

## 🧪 CHẠY BÀI KIỂM THỬ ĐỘ CHUẨN HOÁ (TEST SUITE)

```bash
# Kiểm tra 80 phong cách và độ khớp mã Luau
python tests/run_tests.py
```
Hoặc mở file `tests/fidelity_test.html` trên trình duyệt để theo dõi bảng chấm điểm 80/80 phong cách trực quan!

---

## 🌐 HƯỚNG DẪN DEPLOY LÊN GITHUB PAGES

1. Khởi tạo và đẩy mã nguồn lên GitHub:
   ```bash
   git init
   git add .
   git commit -m "feat: complete 80 independent Roblox UI libraries with live customizer and Luau transpiler"
   git remote add origin https://github.com/<YOUR_USER>/UI-Library.git
   git branch -M main
   git push -u origin main
   ```
2. Trên GitHub, vào mục **Settings** ➔ **Pages**.
3. Tại **Build and deployment** ➔ **Source**, chọn **Deploy from a branch**.
4. Chọn branch `main` và thư mục `/ (root)`, nhấn **Save**.
5. Trang web sẽ trực tiếp khả dụng tại: `https://<YOUR_USER>.github.io/UI-Library/`!
