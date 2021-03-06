const Router = require('koa-router');
const customerHasItemsCtrl = require('./customer-has-items.ctrl');
const { checkToken } = require('../../lib/token');

const router = new Router();

router.post('/', checkToken, customerHasItemsCtrl.create);
router.get('/', checkToken, customerHasItemsCtrl.getAll);
router.get('/:id', customerHasItemsCtrl.getById);
router.put('/:id', customerHasItemsCtrl.updateById);
router.post('/pay', customerHasItemsCtrl.pay);

module.exports = router;
