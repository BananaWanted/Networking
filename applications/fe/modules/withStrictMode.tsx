import React from "react";

export default function withStrictMode(Component: typeof React.Component) {
    return class extends React.Component<any, any> {
        render() {
            return (
                <React.StrictMode>
                    <Component {...this.props} />
                </React.StrictMode>
            )
        }
    }
}