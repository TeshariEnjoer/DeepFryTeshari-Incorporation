import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Trade = {
  id: string;
  name: string;
  description: string;
  price: number;
  stock: number;
  item_amount: number;
};

type NpcTraderData = {
  npc_name: string;
  money: number;

  ui_theme: string;

  dialogue: string;

  trader_portrait: string;
  user_portrait: string;

  sell: Trade[];
  buy: Trade[];
};

const Portrait = (props: { portrait: string; player?: boolean }) => {
  const { portrait, player = false } = props;

  return (
    <Box
      width="100%"
      height="100%"
      position="relative"
      overflow="hidden"
      backgroundColor="#111"
    >
      <img
        src={`data:image/png;base64,${portrait}`}
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          objectFit: 'cover',
          imageRendering: 'pixelated',

          transform: player ? 'scale(1.2)' : 'scale(1.5)',

          transformOrigin: player ? 'center center' : 'center 30%',
        }}
      />
    </Box>
  );
};

const Dialogue = () => {
  const { data } = useBackend<NpcTraderData>();

  const { npc_name, dialogue } = data;

  return (
    <Section
      title={
        <Flex align="center">
          <Icon name="comment" mr={1} />

          {npc_name}
        </Flex>
      }
      fill
    >
      <Box
        height="100%"
        overflow="auto"
        p={1}
        fontSize="1.05rem"
        lineHeight="1.4"
      >
        {dialogue || '...'}
      </Box>
    </Section>
  );
};

const TraderPanel = () => {
  const {
    data: { npc_name, trader_portrait },
  } = useBackend<NpcTraderData>();

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section title={npc_name} fill p={0}>
          <Portrait portrait={trader_portrait} />
        </Section>
      </Stack.Item>

      <Stack.Item basis="170px">
        <Dialogue />
      </Stack.Item>
    </Stack>
  );
};

const PlayerPanel = () => {
  const {
    data: { user_portrait, money },
  } = useBackend<NpcTraderData>();

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section title="You" fill p={0}>
          <Portrait portrait={user_portrait} player />
        </Section>
      </Stack.Item>

      <Stack.Item basis="170px">
        <Section title="Your Funds" fill>
          <LabeledList>
            <LabeledList.Item label="Cash">
              <Box color="good" bold fontSize="1.2rem">
                <Icon name="money-bill" mr={1} />${money.toLocaleString()}
              </Box>
            </LabeledList.Item>

            <LabeledList.Item label="Status">
              <Box color="good">Trading</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const TradeList = (props: { trades: Trade[]; action: 'buy' | 'sell' }) => {
  const { trades, action } = props;

  if (!trades.length) {
    return (
      <Box p={3} color="label" textAlign="center">
        No offers available.
      </Box>
    );
  }

  return (
    <Stack vertical fill>
      {trades.map((trade) => (
        <TradeEntry key={trade.id} trade={trade} action={action} />
      ))}
    </Stack>
  );
};

const TradeEntry = (props: { trade: Trade; action: 'buy' | 'sell' }) => {
  const { trade, action } = props;

  const { act } = useBackend<NpcTraderData>();

  const soldOut = trade.stock <= 0;

  return (
    <Section p={1}>
      <Flex align="center" spacing={2}>
        <Flex.Item grow>
          <Stack vertical>
            <Stack.Item>
              <Flex align="center">
                <Icon name={action === 'buy' ? 'shopping-bag' : 'box'} mr={1} />

                <Box bold fontSize="1.1rem">
                  {trade.name}
                </Box>
              </Flex>
            </Stack.Item>

            {trade.description && (
              <Stack.Item>
                <Box ml={3} color="label">
                  {trade.description}
                </Box>
              </Stack.Item>
            )}

            <Stack.Item>
              <Flex ml={3} align="center">
                <Box color="good" bold mr={2}>
                  ${trade.price.toLocaleString()}
                </Box>

                <Tooltip
                  content={
                    trade.stock === Infinity
                      ? 'Unlimited stock'
                      : `${trade.stock} transactions remaining`
                  }
                >
                  <Box color="label">
                    {trade.stock === Infinity
                      ? 'Unlimited'
                      : `${trade.stock} left`}
                  </Box>
                </Tooltip>
              </Flex>
            </Stack.Item>

            {trade.item_amount > 1 && (
              <Stack.Item>
                <Box ml={3} color="label" fontSize="0.85rem">
                  Quantity: {trade.item_amount}
                </Box>
              </Stack.Item>
            )}
          </Stack>
        </Flex.Item>

        <Flex.Item>
          <Button
            icon={action === 'buy' ? 'shopping-cart' : 'coins'}
            disabled={soldOut}
            onClick={() =>
              act(action, {
                id: trade.id,
              })
            }
          >
            {soldOut ? 'Sold Out' : action === 'buy' ? 'Buy' : 'Sell'}
          </Button>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const TradingPanel = () => {
  const {
    data: { npc_name, money, sell, buy },
  } = useBackend<NpcTraderData>();

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section
          title={
            <Flex align="center" justify="space-between">
              <Box>
                <Icon name="exchange-alt" mr={1} />
                Trading with {npc_name}
              </Box>

              <Box color="good" bold>
                <Icon name="money-bill" mr={1} />${money.toLocaleString()}
              </Box>
            </Flex>
          }
        >
          <Box textAlign="center" color="label">
            Select an offer.
          </Box>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section fill p={1}>
          <Tabs>
            <Tabs.Tab icon="shopping-cart">
              <TradeList trades={sell} action="buy" />
            </Tabs.Tab>

            <Tabs.Tab icon="coins">
              <TradeList trades={buy} action="sell" />
            </Tabs.Tab>
          </Tabs>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section>
          <Box textAlign="center" color="label" fontSize="0.85rem">
            <Icon name="eye" mr={1} />
            You must remain visible to the trader.
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const NpcTrader = () => {
  const {
    data: { ui_theme },
  } = useBackend<NpcTraderData>();

  return (
    <Window width={1150} height={700} theme={ui_theme}>
      <Window.Content>
        <Flex direction="row" spacing={2} height="100%">
          <Flex.Item basis={0} grow={1} minWidth="280px">
            <TraderPanel />
          </Flex.Item>

          <Flex.Item basis={0} grow={1.5} minWidth="400px">
            <TradingPanel />
          </Flex.Item>

          <Flex.Item basis={0} grow={1} minWidth="280px">
            <PlayerPanel />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
