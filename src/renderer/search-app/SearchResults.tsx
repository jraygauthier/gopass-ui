import * as React from 'react'
import * as m from 'react-materialize'
import * as replace from 'string-replace-to-array'
import Gopass from '../secrets/Gopass'
import * as KeyboardEventHandler from 'react-keyboard-event-handler'

const NUMBER_OF_SEARCH_RESULTS = 15

interface SearchResultsState {
    results: string[]
    secretNames: string[]
    filteredSecretNames: string[]
    searchValues: string[]
    selectedItemIndex: number
}
interface SearchResultsProps {
    search?: string
}

export default class SearchResults extends React.Component<SearchResultsProps, SearchResultsState> {
    constructor(props: any) {
        super(props)
        this.state = {
            results: [],
            secretNames: [],
            filteredSecretNames: [],
            searchValues: [],
            selectedItemIndex: 0
        }
    }

    public async componentDidMount() {
        const secretNames = await Gopass.getAllSecretNames()

        this.setState({
            secretNames
        })

        this.updateFilteredSecrets()
    }

    public componentWillReceiveProps(props: SearchResultsProps) {
        this.updateFilteredSecrets(props.search)
    }

    public render() {
        const highlightRegExp = this.state.searchValues.length > 0 ? new RegExp(`(${this.state.searchValues.join('|')})`, 'g') : undefined

        return (
            <div>
                <KeyboardEventHandler handleKeys={ [ 'up', 'shift+tab', 'down', 'tab', 'enter' ] } handleFocusableElements onKeyEvent={ this.onKeyEvent } />
                <m.Collection>
                    { this.state.filteredSecretNames.map((secretName, i) => {
                        const splittedSecretName = secretName.split('/')
                        const isSelected = i === this.state.selectedItemIndex ? 'selected' : undefined

                        return (
                            <m.CollectionItem key={ `secret-${i}` } className={ isSelected }>
                                {splittedSecretName.reduce(
                                    (result: string[], segment, currentIndex) => {
                                        const extendedResult = result.concat(
                                            this.getHighlightedSegment(segment, highlightRegExp)
                                        )

                                        if (currentIndex < splittedSecretName.length - 1) {
                                            extendedResult.push(' > ')
                                        }

                                        return extendedResult
                                    },
                                    [ ]
                                )}
                            </m.CollectionItem>
                        )
                    } ) }
                </m.Collection>
            </div>
        )
    }

    private updateFilteredSecrets = (search?: string) => {
        if (search) {
            const searchValues = search.split(' ').map(searchValue => searchValue.trim())
            this.setState({
                searchValues,
                filteredSecretNames: this.state.secretNames.filter(this.filterMatchingSecrets(searchValues)).slice(0, NUMBER_OF_SEARCH_RESULTS),
                selectedItemIndex: 0
            })
        } else {
            this.setState({
                searchValues: [],
                filteredSecretNames: this.state.secretNames.slice(0, NUMBER_OF_SEARCH_RESULTS),
                selectedItemIndex: 0
            })
        }
    }

    private onKeyEvent = (key: string, event: any) => {
        switch (key) {
            case 'shift+tab':
            case 'up':
                if (this.state.selectedItemIndex > 0) {
                    this.setState({
                        selectedItemIndex: this.state.selectedItemIndex - 1
                    })
                    event.preventDefault()
                }
                break
            case 'down':
            case 'tab':
                if (this.state.selectedItemIndex < this.state.filteredSecretNames.length) {
                    this.setState({
                        selectedItemIndex: this.state.selectedItemIndex + 1
                    })
                    event.preventDefault()
                }
                break
            case 'enter':
                const secretKey = this.state.filteredSecretNames[this.state.selectedItemIndex]
                if (secretKey) {
                    Gopass.show(secretKey).then(value => {
                        console.log(value)
                    })
                }

                event.preventDefault()
                break
        }
    }

    private getHighlightedSegment = (segment: string, highlightRegExp?: RegExp) => {
        if (!highlightRegExp) {
            return segment
        }

        return replace(segment, highlightRegExp, (_: any, match: string, offset: number) => {
            return <mark key={`highlight-${segment}-${offset}`}>{match}</mark>
        })
    }

    private filterMatchingSecrets = (searchValues: string[]) => (secretName: string) => {
        return searchValues.every(searchValue => secretName.includes(searchValue))
    }
}