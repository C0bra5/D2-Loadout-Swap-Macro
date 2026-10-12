const CLICK_COLORS = [ "black", "white" ];
const GEAR_SLOT_NAMES = ["Helmet", "Arms", "Chest", "Legs", "ClassItem" ]
const LOADOUT_GRID_SIZE = [4,5];

const STATE = {};
STATE.clickColor = 0;
STATE.swapping = false;
STATE.swapCounter = 0;
STATE.clickCounter = 0;
STATE.lastClicked = null;
STATE.lastClickAt = new Date();
STATE.startedAt = new Date();
STATE.swapResetTimeoutID = 0;
STATE.bg = document.getElementById("bg");
STATE.loadoutSlots = [...document.querySelectorAll(".loadout-slot")];
STATE.gearCheckers = [...document.querySelectorAll(".gear-checker")];

const swapCounter = document.getElementById("swapCounter");
const clickCounter = document.getElementById("clickCounter");
const resolutionSelector = document.getElementById("selResolution");
const gearBox = document.getElementById("gearBox");
const loadoutBox = document.getElementById("loadoutBox");


class D2SwapperLayout {
	constructor(width, height) {
		this.name = `${width}x${height}`;
		this.width = width;
		this.height = height;
	}

	getBoxSize() {
		let w, h, x, yg, yl, s;
		const a = this.width / this.height;
		const b = 16 / 9;
		if (b <= a) {
			h = this.height;
			w = h / 9 * 16;
			s = h / 1440;
		}
		else {
			w = this.width;
			h = w / 16 * 9;
			s = w / 2560;
		}
		x = (this.width - w) / 2;
		yg = (this.height - h) / 2;
		yl = this.height - h;
		return {
			w : Math.floor(w),
			h : Math.floor(h),
			x : Math.floor(x),
			yg: Math.floor(yg),
			yl: Math.floor(yl),
			s: s
		};
	}

	activate() {
		const boxSize = this.getBoxSize()

		gearBox.setAttribute("x", boxSize.x)
		gearBox.setAttribute("y", boxSize.yg)
		gearBox.setAttribute("width", boxSize.w)
		gearBox.setAttribute("height", boxSize.h)

		loadoutBox.setAttribute("x", boxSize.x)
		loadoutBox.setAttribute("y", boxSize.yl)
		loadoutBox.setAttribute("width", boxSize.w)
		loadoutBox.setAttribute("height", boxSize.h)

		const baseGearSlotOffsets = [[1816,292], [1816, 460], [1816, 628], [1816, 797], [1816, 964]].map(x => [x[0] / 2560, x[1] / 1440]);
		const checkOffsets = [[66,64],[86, 44],[66, 64],[77,31],[66,64]].map(x => [x[0] * boxSize.s, x[1] * boxSize.s]);
		const loadoutOffsets = [98, 456].map(x => x * boxSize.s);
		STATE.bg.style.backgroundImage = `url(./screenshots/${this.width}x${this.height}.png)`
		STATE.bg.setAttribute("viewBox", `0 0 ${this.width} ${this.height}`)
		STATE.bg.setAttribute("width", this.width);
		STATE.bg.setAttribute("height", this.height);
		const gearSize = Math.floor(128 * boxSize.s);
		const loadoutSize = Math.floor(118 * boxSize.s);
		for (let i = 0; i < GEAR_SLOT_NAMES.length; i++) {
			const slotName = GEAR_SLOT_NAMES[i];
			const slot = document.getElementById(slotName + "Slot");
			const checker = document.getElementById(slotName + "Checker");
			if (slot == null || checker == null) continue;

			const pos = baseGearSlotOffsets[i];
			const x = boxSize.x + (boxSize.w * pos[0]);
			const y = boxSize.yg + (boxSize.h * pos[1]);
			slot.setAttribute("x", Math.floor(x));
			slot.setAttribute("y", Math.floor(y));
			slot.setAttribute("width", gearSize);
			slot.setAttribute("height", gearSize);

			const check = checkOffsets[i];
			checker.setAttribute("x", Math.floor(x + check[0]) - 5);
			checker.setAttribute("y", Math.floor(y + check[1]) - 5);
			checker.setAttribute("width", 10);
			checker.setAttribute("height", 10);
		}
		for (let y = 0; y < LOADOUT_GRID_SIZE[1]; y++) {
			for (let x = 0; x < LOADOUT_GRID_SIZE[0]; x++) {
				let i = y * LOADOUT_GRID_SIZE[0] + x;
				const elem = document.getElementById(`loadout${i}`);
				const a = boxSize.x + loadoutOffsets[0] + x * gearSize;
				const b = boxSize.yl + loadoutOffsets[1] + y * gearSize;
				elem.setAttribute("x", Math.floor(a));
				elem.setAttribute("y", Math.floor(b));
				elem.setAttribute("width", Math.floor(loadoutSize));
				elem.setAttribute("height", Math.floor(loadoutSize));
			}
		}
	}
}
function Map(...args) {
	return args;
}

STATE.resolutions = [
	new D2SwapperLayout(1280, 1024),
	new D2SwapperLayout(1280, 1080),
	new D2SwapperLayout(1280, 1440),
	new D2SwapperLayout(1280, 720),
	new D2SwapperLayout(1280, 768),
	new D2SwapperLayout(1280, 800),
	new D2SwapperLayout(1280, 960),
	new D2SwapperLayout(1360, 768),
	new D2SwapperLayout(1366, 768),
	new D2SwapperLayout(1440, 1080),
	new D2SwapperLayout(1440, 900),
	new D2SwapperLayout(1600, 1024),
	new D2SwapperLayout(1600, 1200),
	new D2SwapperLayout(1600, 900),
	new D2SwapperLayout(1680, 1050),
	new D2SwapperLayout(1920, 1080),
	new D2SwapperLayout(1920, 1200),
	new D2SwapperLayout(1920, 1440),
	new D2SwapperLayout(1920, 720),
	new D2SwapperLayout(2048, 1280),
	new D2SwapperLayout(2304, 1440),
	new D2SwapperLayout(2560, 1080),
	new D2SwapperLayout(2560, 1440),
	new D2SwapperLayout(2560, 1600),
	new D2SwapperLayout(3440, 1440),
	new D2SwapperLayout(3840, 2160),
]

function getRandomColor() {
	return CLICK_COLORS[STATE.clickColor = (STATE.clickColor + 1) % CLICK_COLORS.length];
}
function createCircle(x,y) {
	const div = document.createElement("div");
	const color = getRandomColor();
	x -= 50;
	y -= 50;
	div.innerHTML = `<svg class="circle" style="left: ${x}px;top: ${y}px" height="100" width="100" xmlns="http://www.w3.org/2000/svg"><circle r="45" cx="50" cy="50" fill="${color}" /></svg>`;
	const svg = div.children[0];
	return svg;
}
function appendAndKillIn(elem, killIn) {
	document.body.append(elem);
	setTimeout(() => {
		elem.remove();
	}, killIn);
}

function recolorSlots() {
	const color = STATE.gearCheckers[0].getAttribute("fill") == "red" ? "green" : "red";
	for (const elem of STATE.gearCheckers) {
		elem.setAttribute("fill", color);
	}
}

function updateCounters() {
	swapCounter.innerText = `${STATE.swapCounter}`;
	if (STATE.clickCounter > 1) {
		const startDeltaSeconds = (new Date() - STATE.startedAt) / 1000;
		clickCounter.innerText = `${STATE.clickCounter} (${(STATE.clickCounter / startDeltaSeconds).toFixed(3)} cps)`;
	}
	else {
		clickCounter.innerText = `${STATE.clickCounter}`;
	}
}

function gaussianRandom(mean=0, stdev=1) {
    const u = 1 - Math.random(); // Converting [0,1) to (0,1]
    const v = Math.random();
    const z = Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v );
    // Transform to the desired mean and standard deviation:
    return z * stdev + mean;
}

/**
 * @param {MouseEvent} ev 
 */
function onLoadoutSwapped(ev) {
	const now = new Date();
	const diff = now - STATE.lastClickAt;
	if (diff > 500) {
		STATE.swapCounter = 0;
		STATE.clickCounter = 0;
		STATE.lastClicked = null;
		STATE.startedAt = now;
	}
	STATE.lastClickAt = now;
	// check if the click is on an other thing
	if (STATE.lastClicked == ev.target) {
		return;
	}
	STATE.lastClicked = ev.target;
	STATE.clickCounter++;
	updateCounters();
	if (!STATE.swapping) {
		STATE.swapping = true;
		setTimeout(() => {
			recolorSlots()
			STATE.swapCounter++;
			updateCounters();
			STATE.swapping = false;
		}, 450 + Math.round(gaussianRandom(0, 10)))
	}
}
function updateLayout() {
	const w = window.outerWidth;
	const h = window.outerHeight;
	new D2SwapperLayout(w, h).activate()
}

window.addEventListener("resize", updateLayout)


STATE.resolutions.forEach((e,i,a) => {
	const option = document.createElement("option");
	option.value = i;
	option.innerText = e.name;
	resolutionSelector.appendChild(option);
})
resolutionSelector.addEventListener("change", e => {
	STATE.resolutions[resolutionSelector.value].activate()
})
document.getElementById("btnShowSlots").addEventListener("click", () => {
	document.body.classList.toggle("highlight-slots")
})
document.getElementById("btnShowBoxes").addEventListener("click", () => {
	document.body.classList.toggle("highlight-boxes")
})
STATE.bg.addEventListener("mousedown", (ev) => {
	appendAndKillIn(createCircle(ev.x, ev.y), 1000);
})
STATE.loadoutSlots.forEach(x => x.addEventListener("mousedown", onLoadoutSwapped))
STATE.resolutions[0].activate()
updateLayout();