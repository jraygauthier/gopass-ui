import { ipcRenderer } from 'electron'

export interface HistoryEntry {
    hash: string
    author: string
    timestamp: string
    message: string
}

const lineSplitRegex = /\r?\n/
const isDefined = (value: string) => !!value

let executionId = 1

export default class Gopass {
    public static copy(key: string): Promise<string> {
        //return Gopass.execute(`show ${key} -c`)
        //return 'something'

        return new Promise((resolve, reject) => {
            setTimeout(() => resolve('something'), 300)
        })
    }

    public static show(key: string): Promise<string> {
        //return Gopass.execute(`show ${key}`)
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                resolve(btoa(key))
            }, 500)
        })
    }

    public static async history(key: string): Promise<HistoryEntry[]> {
        /*return (await Gopass.execute(`history ${key}`))
            .split(lineSplitRegex)
            .filter(isDefined)
            .map(historyLine => {
                const lineSplit = historyLine.split(' - ')

                return {
                    hash: lineSplit[0],
                    author: lineSplit[1],
                    timestamp: lineSplit[2],
                    message: lineSplit[3]
                }
            })*/
        return [
            {
                hash: 'asdf42s',
                author: 'Matthias Rütten <matthias.ruetten@codecentric.de>',
                timestamp: new Date() as any,
                message: 'Removed Recipient 640F1D1D0E31A7BDEEEB8D99E8E300B26BE714EF'
            },
            {
                hash: '512sfasdasd',
                author: 'Jonas Verhoelen <jonas.verhoelen@codecentric.de>',
                timestamp: new Date() as any,
                message: 'Created this secret'
            }
        ]
    }

    public static async sync(): Promise<void> {
        await Gopass.execute('sync')
    }

    public static async getAllSecretNames(): Promise<string[]> {
        //const flatSecrets = await Gopass.execute('list', ['--flat'])

        // return flatSecrets.split(lineSplitRegex).filter(isDefined)
        return [
            'codecentric/cassandra/url',
            'codecentric/cassandra/username',
            'codecentric/cassandra/password',
            'codecentric/twenty-percent-time/some-stuff',
            'codecentric/docker-registry/username',
            'codecentric/docker-registry/password',
            'codecentric/docker-registry/url',
            'codecentric/keycloak/username',
            'codecentric/keycloak/password',
            'codecentric/keycloak/url',
            'codecentric/kubernetes/dev/username',
            'codecentric/kubernetes/dev/password',
            'codecentric/kubernetes/dev/host',
            'codecentric/kubernetes/prod/username',
            'codecentric/kubernetes/prod/password',
            'codecentric/opsgenie/username',
            'codecentric/opsgenie/password',
            'codecentric/slack/username',
            'codecentric/slack/password',
            'codecentric/kibana/username',
            'codecentric/kibana/password',
            'open-source/gopass-ui/some-secret',
            'open-source/golumbus/some-secret',
            'open-source/fish-history-to-zsh/some-secret',
            'open-source/node-cassandra-migration/some-secret',
            'open-source/react-mobx-i18n/some-secret',
        ]
    }

    private static execute(command: string, args?: string[]): Promise<string> {
        executionId++

        const result = new Promise<string>((resolve, reject) => {
            ipcRenderer.once(`gopass-answer-${executionId}`, (_: Event, value: any) => {
                if (value.status === 'ERROR') {
                    reject(value.payload)
                } else {
                    resolve(value.payload)
                }
            })
        })

        ipcRenderer.send('gopass', { executionId, command, args })

        return result
    }
}
