import {
  GRID_SIZE,
  createInitialState,
  setDirection,
  tick,
} from './logic.mjs';

const TICK_MS = 140;

const boardEl = document.getElementById('board');
const scoreEl = document.getElementById('score');
const messageEl = document.getElementById('message');
const restartEl = document.getElementById('restart');
const pauseEl = document.getElementById('pause');

let state = createInitialState();
let timerId = null;
let isPaused = false;

function renderBoard() {
  const snakeSet = new Set(state.snake.map((s) => `${s.x},${s.y}`));
  const foodKey = state.food ? `${state.food.x},${state.food.y}` : '';
  const cells = [];

  for (let y = 0; y < GRID_SIZE; y += 1) {
    for (let x = 0; x < GRID_SIZE; x += 1) {
      const key = `${x},${y}`;
      let cls = 'cell';

      if (snakeSet.has(key)) {
        cls += ' snake';
      } else if (key === foodKey) {
        cls += ' food';
      }

      cells.push(`<div class="${cls}" role="gridcell" aria-label="${x},${y}"></div>`);
    }
  }

  boardEl.innerHTML = cells.join('');
  scoreEl.textContent = String(state.score);
  if (state.isGameOver) {
    messageEl.textContent = 'Game over. Press Restart or Space to play again.';
  } else if (isPaused) {
    messageEl.textContent = 'Paused.';
  } else {
    messageEl.textContent = '';
  }
}

function startLoop() {
  stopLoop();
  timerId = window.setInterval(() => {
    state = tick(state);
    renderBoard();

    if (state.isGameOver) {
      stopLoop();
    }
  }, TICK_MS);
}

function stopLoop() {
  if (timerId !== null) {
    window.clearInterval(timerId);
    timerId = null;
  }
}

function restartGame() {
  state = createInitialState();
  isPaused = false;
  pauseEl.textContent = 'Pause';
  renderBoard();
  startLoop();
}

function handleDirectionInput(dir) {
  if (isPaused || state.isGameOver) {
    return;
  }
  state = setDirection(state, dir);
}

function togglePause() {
  if (state.isGameOver) {
    return;
  }

  isPaused = !isPaused;
  pauseEl.textContent = isPaused ? 'Resume' : 'Pause';

  if (isPaused) {
    stopLoop();
  } else {
    startLoop();
  }
  renderBoard();
}

function onKeyDown(event) {
  const key = event.key.toLowerCase();
  const map = {
    arrowup: 'up',
    w: 'up',
    arrowdown: 'down',
    s: 'down',
    arrowleft: 'left',
    a: 'left',
    arrowright: 'right',
    d: 'right',
  };

  if (key === ' ' && state.isGameOver) {
    restartGame();
    return;
  }

  if (key === 'p') {
    togglePause();
    return;
  }

  if (map[key]) {
    event.preventDefault();
    handleDirectionInput(map[key]);
  }
}

document.addEventListener('keydown', onKeyDown);

for (const button of document.querySelectorAll('[data-dir]')) {
  button.addEventListener('click', () => {
    handleDirectionInput(button.dataset.dir);
  });
}

restartEl.addEventListener('click', restartGame);
pauseEl.addEventListener('click', togglePause);

renderBoard();
startLoop();
