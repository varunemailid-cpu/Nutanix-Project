import test from 'node:test';
import assert from 'node:assert/strict';
import {
  GRID_SIZE,
  createInitialState,
  setDirection,
  tick,
  spawnFood,
} from '../src/logic.mjs';

function rngFrom(values) {
  let i = 0;
  return () => {
    const v = values[i] ?? values[values.length - 1] ?? 0;
    i += 1;
    return v;
  };
}

test('snake moves one cell in current direction on tick', () => {
  const state = createInitialState(() => 0);
  const next = tick(state, () => 0);

  assert.equal(next.snake[0].x, state.snake[0].x + 1);
  assert.equal(next.snake[0].y, state.snake[0].y);
  assert.equal(next.snake.length, state.snake.length);
});

test('snake grows and score increments when eating food', () => {
  const start = createInitialState(() => 0);
  const state = {
    ...start,
    food: { x: start.snake[0].x + 1, y: start.snake[0].y },
  };

  const next = tick(state, () => 0);

  assert.equal(next.score, 1);
  assert.equal(next.snake.length, state.snake.length + 1);
  assert.notDeepEqual(next.food, state.food);
});

test('setDirection rejects immediate reverse direction', () => {
  const state = createInitialState(() => 0);
  const reversed = setDirection(state, 'left');

  assert.equal(reversed.nextDirection, 'right');
});

test('game over on wall collision', () => {
  const state = {
    ...createInitialState(() => 0),
    snake: [{ x: GRID_SIZE - 1, y: 0 }, { x: GRID_SIZE - 2, y: 0 }],
    direction: 'right',
    nextDirection: 'right',
  };

  const next = tick(state, () => 0);
  assert.equal(next.isGameOver, true);
});

test('game over on self collision', () => {
  const state = {
    ...createInitialState(() => 0),
    snake: [
      { x: 2, y: 2 },
      { x: 2, y: 3 },
      { x: 1, y: 3 },
      { x: 1, y: 2 },
    ],
    direction: 'down',
    nextDirection: 'down',
  };

  const next = tick(state, () => 0);
  assert.equal(next.isGameOver, true);
});

test('moving into previous tail cell is allowed when not eating', () => {
  const state = {
    ...createInitialState(() => 0),
    snake: [
      { x: 2, y: 2 },
      { x: 2, y: 3 },
      { x: 1, y: 3 },
      { x: 1, y: 2 },
    ],
    direction: 'left',
    nextDirection: 'left',
    food: { x: 10, y: 10 },
  };

  const next = tick(state, () => 0);
  assert.equal(next.isGameOver, false);
  assert.deepEqual(next.snake[0], { x: 1, y: 2 });
});

test('spawnFood never places food on snake', () => {
  const snake = [
    { x: 0, y: 0 },
    { x: 1, y: 0 },
    { x: 2, y: 0 },
  ];
  const food = spawnFood(snake, rngFrom([0, 0.5, 0.9]));

  assert.ok(food);
  assert.equal(snake.some((s) => s.x === food.x && s.y === food.y), false);
});
