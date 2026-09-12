import { NoticeBox } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  url: string;
};

// The whole interface is the page. Closing and reopening the window is what reloads it, since the
// frame is cross origin and its location cannot be read or set from out here.
export const WikiBrowser = (props) => {
  const { data } = useBackend<Data>();
  const { url } = data;

  return (
    <Window title="Wiki" width={900} height={700}>
      <Window.Content>
        {url ? (
          <iframe
            src={url}
            title="Wiki"
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
          <NoticeBox>This laptop has no address set.</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};
