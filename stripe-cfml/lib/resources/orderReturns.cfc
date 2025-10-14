component {

    this.metadata = {
        methods: {
            'list': {
                arguments: {
                    created: 'datefilter'
                },
                path: '/order_returns'
            },
            'retrieve': {
                path: '/order_returns/{order_return_id}'
            }
        }
    };

}
