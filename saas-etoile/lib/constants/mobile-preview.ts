/**
 * Mobile Preview Constants
 * Hard-coded dimensions mirroring Flutter mobile app feed (9:16 aspect ratio)
 */

export const MOBILE_PREVIEW = {
  ASPECT: 9 / 16,
  WIDTH: 375, // iPhone standard width
  HEIGHT: 667, // iPhone standard height (375 * 16/9)
  FRAME_PADDING: 20, // Padding around mobile frame
} as const;

export const DESKTOP_PREVIEW = {
  ASPECT: 16 / 9,
  WIDTH: 640,
  HEIGHT: 360,
} as const;
