const CLICK_COLORS = [ "black", "white" ];
const GEAR_SLOT_NAMES = ["Helmet", "Arms", "Chest", "Legs", "ClassItem" ]
const LOADOUT_GRID_SIZE = [4,5];

const ELEMS = {
	/** @type {HTMLSpanElement} */
	clickCounter: document.getElementById("clickCounter"),
	/** @type {HTMLSpanElement} */
	goodSwapCounter: document.getElementById("goodSwapCounter"),
	/** @type {HTMLSpanElement} */
	badSwapCounter: document.getElementById("badSwapCounter"),
	/** @type {HTMLSpanElement} */
	streakTimer: document.getElementById("streakTimer"),
	/** @type {HTMLSpanElement} */
	usedSlotCounter: document.getElementById("usedSlotCounter"),
	/** @type {HTMLSelectElement} */
	selResolution: document.getElementById("selResolution"),
	/** @type {SVGRectElement} */
	gearBox: document.getElementById("gearBox"),
	/** @type {SVGRectElement} */
	loadoutBox: document.getElementById("loadoutBox"),
	/** @type {HTMLButtonElement} */
	txtChangeMean: document.getElementById("txtChangeMean"),
	/** @type {HTMLButtonElement} */
	txtChangeSD: document.getElementById("txtChangeSD"),
	/** @type {SVGSVGElement} */
	bg: document.getElementById("bg"),
	/** @type {SVGRectElement[]} */
	loadoutSlots: [...document.querySelectorAll(".loadout-slot")],
	/** @type {SVGRectElement[]} */
	gearCheckers: [...document.querySelectorAll(".gear-checker")],
};

/**
 * @param {number} mean 
 * @param {number} stdev 
 * @returns {number}
 */
function gaussianRandom(mean=0, stdev=1) {
    const u = 1 - Math.random(); // Converting [0,1) to (0,1]
    const v = Math.random();
    const z = Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v );
    // Transform to the desired mean and standard deviation:
    return z * stdev + mean;
}

class TesterState {
	constructor() {
		this.clickColor = 0;
		this.swapping = false;
		this.swapCounter = 0;
		this.badSwapCounter = 0;
		this.clickCounter = 0;
		/** @type {string?} */
		this.lastClicked = null;
		/** @type {string?} */
		this.lastSwapped = null;
		/** @type {Object<string,boolean>} */
		this.usedSlotTracker = {};
		this.usedSlotCounter = 0;
		this.changeMean = 160;
		this.changeSD = 10;
		this.lastClickAt = new Date();
		this.startedAt = new Date();
		this.isStandalone = document.getElementById("standaloneScript") != null;
	}

	getSwapDelay() {
		if (this.changeSD <= 0) {
			return this.changeMean;
		}
		return Math.round(gaussianRandom(this.changeMean, this.changeSD))
	}

	updateChangeMean() {
		let parsed = parseInt(ELEMS.txtChangeMean.value);
		if (isNaN(parsed)) parsed = 160;
		this.changeMean = Math.min(0, parsed);
	}

	updateChangeSD() {
		let parsed = parseInt(ELEMS.txtChangeSD.value);
		if (isNaN(parsed)) parsed = 10;
		this.changeSD = Math.max(0, parsed);
	}

	/**
	 * @param {Date} now 
	 */
	resetStreak(now) {
		this.swapCounter = 0;
		this.clickCounter = 0;
		this.lastClicked = null;
		this.lastSwapped = null;
		this.startedAt = now;
		this.badSwapCounter = 0;
		this.usedSlotCounter = 0;
		this.usedSlotTracker = {};
	}
}
const STATE = new TesterState();

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

		ELEMS.gearBox.setAttribute("x", boxSize.x)
		ELEMS.gearBox.setAttribute("y", boxSize.yg)
		ELEMS.gearBox.setAttribute("width", boxSize.w)
		ELEMS.gearBox.setAttribute("height", boxSize.h)

		ELEMS.loadoutBox.setAttribute("x", boxSize.x)
		ELEMS.loadoutBox.setAttribute("y", boxSize.yl)
		ELEMS.loadoutBox.setAttribute("width", boxSize.w)
		ELEMS.loadoutBox.setAttribute("height", boxSize.h)

		const baseGearSlotOffsets = [[1816,292], [1816, 460], [1816, 628], [1816, 797], [1816, 964]].map(x => [x[0] / 2560, x[1] / 1440]);
		const checkOffsets = [[66,64],[86, 44],[66, 64],[77,31],[66,64]].map(x => [x[0] * boxSize.s, x[1] * boxSize.s]);
		const loadoutOffsets = [98, 456].map(x => x * boxSize.s);
		if (!STATE.isStandalone) {
			ELEMS.bg.style.backgroundImage = `url(./screenshots/${this.width}x${this.height}.png)`
		}
		ELEMS.bg.setAttribute("viewBox", `0 0 ${this.width} ${this.height}`)
		ELEMS.bg.setAttribute("width", this.width);
		ELEMS.bg.setAttribute("height", this.height);
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

/**
 * @param {string} color 
 */
function recolorSlots(color) {
	for (const elem of ELEMS.gearCheckers) {
		elem.setAttribute("fill", color);
	}
}

function updateCounters() {
	const now = new Date();
	ELEMS.goodSwapCounter.innerText = `${STATE.swapCounter}`;
	ELEMS.badSwapCounter.innerText = `${STATE.badSwapCounter}`;
	ELEMS.usedSlotCounter.innerText = `${STATE.usedSlotCounter}`;
	const delta = now - STATE.startedAt;
	ELEMS.streakTimer.innerText = (delta / 1000).toFixed(3);
	if (STATE.clickCounter > 1) {
		const startDeltaSeconds = (now - STATE.startedAt) / 1000;
		ELEMS.clickCounter.innerText = `${STATE.clickCounter} (${(STATE.clickCounter / startDeltaSeconds).toFixed(3)} cps)`;
	}
	else {
		ELEMS.clickCounter.innerText = `${STATE.clickCounter}`;
	}
}



/**
 * @param {MouseEvent} ev 
 */
function onLoadoutSwapped(ev) {
	const now = new Date();
	const diff = now - STATE.lastClickAt;
	if (diff > 1000) {
		STATE.resetStreak(now);
	}
	STATE.lastClickAt = now;
	// check if the click is on an other thing
	if (STATE.lastClicked == ev.target.id) {
		return;
	}
	if (STATE.usedSlotTracker[ev.target.id] == null) {
		STATE.usedSlotTracker[ev.target.id] = true;
		STATE.usedSlotCounter++;
	}
	STATE.lastClicked = ev.target.id;
	STATE.clickCounter++;
	updateCounters();
	if (!STATE.swapping) {
		STATE.swapping = true;
		setTimeout(() => {
			recolorSlots(ev.target.getAttribute("data-swap-fill"))
			if (STATE.lastSwapped != ev.target.id) {
				STATE.swapCounter++;
			}
			else {
				STATE.badSwapCounter++;
			}
			STATE.lastSwapped = ev.target.id;
			updateCounters();
			STATE.swapping = false;
		}, STATE.getSwapDelay())
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
	ELEMS.selResolution.appendChild(option);
})
ELEMS.selResolution.addEventListener("change", () => {
	window.removeEventListener("resize", updateLayout)
	STATE.resolutions[ELEMS.selResolution.value].activate()
})
ELEMS.txtChangeMean.addEventListener("change", () => STATE.updateChangeMean())
ELEMS.txtChangeSD.addEventListener("change", () => STATE.updateChangeSD())
document.getElementById("btnShowSlots").addEventListener("click", () => {
	document.body.classList.toggle("highlight-slots")
})
document.getElementById("btnShowBoxes").addEventListener("click", () => {
	document.body.classList.toggle("highlight-boxes")
})
ELEMS.bg.addEventListener("mousedown", (ev) => {
	const color = CLICK_COLORS[STATE.clickColor = (STATE.clickColor + 1) % CLICK_COLORS.length];
	const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
	svg.classList.add("circle");
	svg.style.left = `${ev.x - 50}px`;
	svg.style.top = `${ev.y - 50}px`;
	svg.setAttribute("width", 100);
	svg.setAttribute("height", 100);
	svg.innerHTML = `<circle r="45" cx="50" cy="50" fill="${color}" />`;
	document.body.append(svg);
	setTimeout(() => {
		svg.remove();
	}, 1000);
})
ELEMS.loadoutSlots.forEach(x => x.addEventListener("mousedown", onLoadoutSwapped))
STATE.resolutions[0].activate()
updateLayout();