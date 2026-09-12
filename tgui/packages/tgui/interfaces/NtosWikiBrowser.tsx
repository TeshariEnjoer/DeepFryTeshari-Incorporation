import { useState } from 'react';
import { Box, Button, NoticeBox, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  url: string;
};

export const NtosWikiBrowser = (props) => {
  const { data } = useBackend<Data>();
  const { url } = data;
  // Remounting the frame is the only way back to the bookmark: the page is cross origin, so its
  // location cannot be read or set once a link inside it has moved it on.
  const [visit, setVisit] = useState(0);

  return (
    <NtosWindow width={900} height={700}>
      <NtosWindow.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  <Box color="label" style={{ overflow: 'hidden' }}>
                    {url || 'No address configured.'}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="house"
                    disabled={!url}
                    onClick={() => setVisit(visit + 1)}
                  >
                    Home
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {url ? (
              <iframe
                key={visit}
                src={url}
                title="Reference Browser"
                // No allow-top-navigation and no allow-popups, so the page cannot escape this frame
                sandbox="allow-scripts allow-same-origin allow-forms"
                referrerPolicy="no-referrer"
                allow=""
                style={{
                  width: '100%',
                  height: '100%',
                  border: 0,
                  background: '#ffffff',
                }}
              />
            ) : (
              <NoticeBox>This program has no address set.</NoticeBox>
            )}
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
