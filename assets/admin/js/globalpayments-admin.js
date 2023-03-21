/* global globalpayments_admin_params */

( function(
    $,
    globalpayments_admin_params
) {
    function GlobalPaymentsAdmin( globalpayments_admin_params ) {
        this.id = globalpayments_admin_params.gateway_id;
        this.toggleCredentialsSettings();
        this.toggleValidations();
        this.attachEventHandlers();
        this.validate_cc_types();
    };
    GlobalPaymentsAdmin.prototype = {
        /**
         * Add important event handlers
         *
         * @returns
         */
        attachEventHandlers: function () {
            $( document ).on( 'change', this.getLiveModeSelector(), this.toggleCredentialsSettings.bind( this ) );
            $( document ).on( 'change', this.getEnabledGatewaySelector(), this.toggleValidations.bind( this ) );
            $( document ).on( 'change', $( '.accepted_cards.required' ), this.validate_cc_types.bind( this ) );
            
            // Admin Pay for Order
            $( '#customer_user' ).on( 'change', this.updatePaymentMethods );
            $( '.wc-globalpayments-pay-order' ).on( 'click', this.payForOrder );
            $( document.body ).on('wc_backbone_modal_loaded', this.modalLoaded.bind( this ) );
        },

        updatePaymentMethods: function ( e ) {
            // fetch user payment tokens
            var customer_id = $( e.target ).val();
            globalpayments_admin_params.payment_methods = [];
            if ( customer_id > 0 && typeof globalpayments_admin_params !== "undefined" ) {
                var data = {
                    _wpnonce: globalpayments_admin_params._wpnonce,
                    customer_id: customer_id
                };
                $( '.wc-globalpayments-pay-order' ).prop( 'disabled', true );
                $.get( globalpayments_admin_params.payment_methods_url, data, function ( response ) {
                    globalpayments_admin_params.payment_methods = response;
                    $( '.wc-globalpayments-pay-order' ).prop( 'disabled', false );
                }, 'json' );
            }
        },

        /**
         * Enable modal template.
         *
         * @param e
         */
        payForOrder: function( e ) {
            e.preventDefault();
            $( this ).WCGlobalPaymentsPayOrderBackboneModal({
                template: 'wc-globalpayments-pay-order-modal',
                variable: {
                    customer_id: $( '#customer_user' ).val(),
                    payment_methods: globalpayments_admin_params.payment_methods,
                }
            });
        },

        /**
         * Render modal content.
         *
         * @param e
         * @param target
         */
        modalLoaded: function ( e, target ) {
            switch ( target ) {
                case 'wc-globalpayments-pay-order-modal':
                    $( document.body ).trigger( 'globalpayments_pay_order_modal_loaded' );
                    $( document.body ).trigger( 'wc-credit-card-form-init' );
                    break;
            }
        },

        /**
         * Checks if "Live Mode" setting is enabled
         *
         * @returns {*|jQuery}
         */
        isLiveMode: function() {
            return $( this.getLiveModeSelector() ).is( ':checked' );
        },

        /**
         * Checks if gateway setting is enabled
         *
         * @returns {*|jQuery}
         */
        isEnabled: function() {
            return $( this.getEnabledGatewaySelector() ).is( ':checked' );
        },

        /**
         * Checks if cc_types at least one selected
         */
        validate_cc_types: function () {
            if ( 'globalpayments_googlepay' != this.id) {
                return;
            }
            if ( this.isEnabled() ) {
                var checksitems = $( '.accepted_cards.required' );
                var required = true;
                if ( checksitems && checksitems.length > 0 ) {
                    checksitems.each( function() {
                        if ( $( this ).is( ':checked' ) ) {
                            required = false;
                            checksitems.prop( 'required', false );
                            return;
                        }
                    } );
                    if ( required ) {
                        checksitems.prop( 'required', true );
                    }
                }
            }
        },

        /**
         * Toggle validations when enabled gateway settings
         */
        toggleValidations: function () {
            this.validate_cc_types();

            var button = $('.woocommerce-save-button');
            if ( this.isEnabled() ) {
                button.removeAttr( "formnovalidate" );
            } else {
                button.attr( "formnovalidate","");
            }
        },

        /**
         * Toggle required settings
         */
        toggleRequiredSettings: function () {
            var list =  $('.required');
            list.each(function(){
                if ($(this).is(':visible')) {
                    $(this).prop('required', true);
                } else {
                    $(this).prop('required', false);
                }
            });
        },

        /**
         * Toggle gateway credentials settings
         */
        toggleCredentialsSettings: function () {
            var display = this.isLiveMode();

            $('.live-toggle').parents('tr').toggle(display);
            $('.sandbox-toggle').parents('tr').toggle(!display);

            this.toggleRequiredSettings();
        },

        /**
         * Convenience function to get CSS selector for the "Live Mode" setting
         *
         * @returns {string}
         */
        getLiveModeSelector: function () {
            return '#woocommerce_' + this.id + '_is_production';
        },

        /**
         * Convenience function to get CSS selector for the "Enabled" setting
         *
         * @returns {string}
         */
        getEnabledGatewaySelector: function () {
            return '#woocommerce_' + this.id + '_enabled';
        }
    };
    new GlobalPaymentsAdmin( globalpayments_admin_params );
}(
    /**
     * Global `jQuery` reference
     *
     * @type {any}
     */
    (window).jQuery,
    /**
     * Global `wc_checkout_params` reference
     *
     * @type {any}
     */
    (window).globalpayments_admin_params || {},
));
