import { Notification } from './notificationReducer'

export const SHOW_NOTIFICATION = 'SHOW_NOTIFICATION'
export const HIDE_NOTIFICATION = 'HIDE_NOTIFICATION'

export type ShowNotification = { type: typeof SHOW_NOTIFICATION, payload: Notification }
export type HideNotification = { type: typeof HIDE_NOTIFICATION }

export const showNotification = (notification: Notification): ShowNotification => {
    return { type: SHOW_NOTIFICATION, payload: notification }
}

export const hideNotification = (): HideNotification => {
    return { type: HIDE_NOTIFICATION }
}