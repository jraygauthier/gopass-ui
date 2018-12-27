import * as React from 'react'
import * as m from 'react-materialize'
import { Route, match } from 'react-router-dom'
import { History } from 'history'

import SecretDetails from './crud/SecretDetails'
import FullActionNavigation from './navigation/FullActionNavigation'
import GoBackNavigation from './navigation/GoBackNavigation'
import Settings from './settings/Settings'
import Notification from '../../notifications/Notification'

/* tslint:disable:jsx-no-lambda */
export default class MainContent extends React.Component<{ history: History }, {}> {
    render() {
        const { history } = this.props

        return (
            <div className='main-content'>
                <Notification />
                <m.Row>
                    <m.Col s={12}>
                        <Route
                            path='/'
                            exact
                            render={() => (
                                <div>
                                    <FullActionNavigation history={history} />
                                    <m.CardPanel>
                                        Choose a secret from the navigation or use the actions at the top.
                                    </m.CardPanel>
                                </div>
                            )}
                        />
                        <Route
                            path='/:encodedSecretName/view'
                            render={(props: { match: match<{ encodedSecretName: string }> }) => {
                                const chosenSecretName = atob(props.match.params.encodedSecretName)

                                return (
                                    <div>
                                        <FullActionNavigation history={history} secretName={chosenSecretName} />
                                        <SecretDetails secretName={chosenSecretName} />
                                    </div>
                                )
                            }}
                        />
                        <Route
                            path='/settings'
                            exact
                            render={(props: { history: History }) => (
                                <div>
                                    <GoBackNavigation history={history} />
                                    <Settings history={history} />
                                </div>
                            )}
                        />
                    </m.Col>
                </m.Row>
            </div>
        )
    }
}
