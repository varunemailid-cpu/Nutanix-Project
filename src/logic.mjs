export const GRID_SIZE = 20;
export const DIRECTIONS = {
  up: { x: 0, y: -1 },
  down: { x: 0, y: 1 },
  left: { x: -1, y: 0 },
  right: { x: 1, y: 0 },
};

const OPPOSITES = {
  up: 'down',
  down: 'up',
  left: 'right',
  right: 'left',
};

export function createInitialState(rng = Math.random) {
  const mid = Math.floor(GRID_SIZE / 2);
  const snake = [
    { x: mid, y: mid },
    { x: mid - 1, y: mid },
  ];

  return {
    snake,
    direction: 'right',
    nextDirection: 'right',
    food: spawnFood(snake, rng),
    score: 0,
    isGameOver: false,
  };
}

export function setDirection(state, direction) {
  if (!DIRECTIONS[direction]) {
    return state;
  }

  if (OPPOSITES[state.direction] === direction) {
    return state;
  }

  return {
    ...state,
    nextDirection: direction,
  };
}

export function tick(state, rng = Math.random) {
  if (state.isGameOver) {
    return state;
  }

  const direction = state.nextDirection;
  const head = state.snake[0];
  const move = DIRECTIONS[direction];
  const newHead = { x: head.x + move.x, y: head.y + move.y };
  const ateFood = Boolean(
    state.food && newHead.x === state.food.x && newHead.y === state.food.y
  );
  const collisionSnake = ateFood ? state.snake : state.snake.slice(0, -1);

  if (isWallCollision(newHead) || isSelfCollision(newHead, collisionSnake)) {
    return {
      ...state,
      direction,
      isGameOver: true,
    };
  }

  const newSnake = [newHead, ...state.snake];

  if (!ateFood) {
    newSnake.pop();
  }

  return {
    ...state,
    snake: newSnake,
    direction,
    food: ateFood ? spawnFood(newSnake, rng) : state.food,
    score: ateFood ? state.score + 1 : state.score,
  };
}

export function spawnFood(snake, rng = Math.random) {
  const occupied = new Set(snake.map((segment) => `${segment.x},${segment.y}`));
  const freeCells = [];

  for (let y = 0; y < GRID_SIZE; y += 1) {
    for (let x = 0; x < GRID_SIZE; x += 1) {
      const key = `${x},${y}`;
      if (!occupied.has(key)) {
        freeCells.push({ x, y });
      }
    }
  }

  if (freeCells.length === 0) {
    return null;
  }

  const index = Math.floor(rng() * freeCells.length);
  return freeCells[index];
}

function isWallCollision(point) {
  return (
    point.x < 0 ||
    point.x >= GRID_SIZE ||
    point.y < 0 ||
    point.y >= GRID_SIZE
  );
}

function isSelfCollision(head, snake) {
  return snake.some((segment) => segment.x === head.x && segment.y === head.y);
}
